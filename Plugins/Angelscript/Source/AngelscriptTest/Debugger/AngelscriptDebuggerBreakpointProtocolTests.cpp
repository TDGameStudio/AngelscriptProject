#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakpointProtocolTests_Private
{
	bool StartDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger session should initialize against the debuggable production engine"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger client should connect to the session debug server"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		bool bSentStartDebugging = false;
		const bool bStartMessageSent = Session.PumpUntil(
			[&Client, &bSentStartDebugging]()
			{
				if (bSentStartDebugging)
				{
					return true;
				}

				bSentStartDebugging = Client.SendStartDebugging(2);
				return bSentStartDebugging;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger client should send StartDebugging before breakpoint protocol tests"), bStartMessageSent))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		TOptional<FAngelscriptDebugMessageEnvelope> VersionEnvelope;
		const bool bReceivedVersion = Session.PumpUntil(
			[&Client, &VersionEnvelope]()
			{
				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					VersionEnvelope = MoveTemp(Envelope);
					return true;
				}
				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger client should receive the DebugServerVersion response"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	struct FAsyncModuleInvocationState : public TSharedFromThis<FAsyncModuleInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncModuleInvocationState> DispatchModuleInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncModuleInvocationState> State = MakeShared<FAsyncModuleInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		TSharedRef<FAsyncModuleInvocationState> InvocationState,
		const TCHAR* Context)
	{
		const bool bCompleted = Session.PumpUntil(
			[&InvocationState]()
			{
				return InvocationState->bCompleted.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bCompleted);
	}

	struct FBreakpointMonitorResult
	{
		TArray<FAngelscriptDebugMessageEnvelope> StopEnvelopes;
		TOptional<FAngelscriptCallStack> CapturedCallstack;
		bool bTimedOut = false;
		FString Error;
	};

	struct FBreakpointMonitorConfig
	{
		bool bRequestCallstack = false;
		bool bSendContinueOnStop = true;
		int32 MaxStopsToHandle = 1;
		float TimeoutSeconds = 45.0f;
	};

	TFuture<FBreakpointMonitorResult> StartBreakpointMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		const FBreakpointMonitorConfig& Config)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Config]() -> FBreakpointMonitorResult
			{
				FBreakpointMonitorResult Result;

				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Monitor client failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				const double HandshakeEnd = FPlatformTime::Seconds() + Config.TimeoutSeconds;
				bool bSentStart = false;
				bool bReceivedVersion = false;

				while (FPlatformTime::Seconds() < HandshakeEnd && !bShouldStop.Load())
				{
					if (!bSentStart)
					{
						bSentStart = MonitorClient.SendStartDebugging(2);
					}

					if (bSentStart && !bReceivedVersion)
					{
						TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
						if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
						{
							bReceivedVersion = true;
							break;
						}
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!bReceivedVersion)
				{
					Result.Error = TEXT("Monitor client timed out waiting for DebugServerVersion handshake.");
					bMonitorReady = true;
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
					return Result;
				}

				bMonitorReady = true;

				int32 StopsHandled = 0;
				const double MonitorEnd = FPlatformTime::Seconds() + Config.TimeoutSeconds;

				while (FPlatformTime::Seconds() < MonitorEnd && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (!Envelope.IsSet())
					{
						FPlatformProcess::Sleep(0.001f);
						continue;
					}

					if (Envelope->MessageType == EDebugMessageType::HasStopped)
					{
						Result.StopEnvelopes.Add(Envelope.GetValue());

						if (Config.bRequestCallstack && MonitorClient.SendRequestCallStack())
						{
							const double CallstackEnd = FPlatformTime::Seconds() + 10.0;
							while (FPlatformTime::Seconds() < CallstackEnd)
							{
								TOptional<FAngelscriptDebugMessageEnvelope> CallstackEnvelope = MonitorClient.ReceiveEnvelope();
								if (CallstackEnvelope.IsSet() && CallstackEnvelope->MessageType == EDebugMessageType::CallStack)
								{
									Result.CapturedCallstack = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptCallStack>(CallstackEnvelope.GetValue());
									break;
								}
								FPlatformProcess::Sleep(0.001f);
							}
						}

						if (Config.bSendContinueOnStop)
						{
							MonitorClient.SendContinue();
						}

						++StopsHandled;
						if (StopsHandled >= Config.MaxStopsToHandle)
						{
							break;
						}
					}
				}

				if (StopsHandled == 0 && !bShouldStop.Load() && FPlatformTime::Seconds() >= MonitorEnd)
				{
					Result.bTimedOut = true;
				}

				MonitorClient.SendStopDebugging();
				MonitorClient.SendDisconnect();
				MonitorClient.Disconnect();
				return Result;
			});
	}

	bool StartAndWaitForMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		const FBreakpointMonitorConfig& Config,
		TFuture<FBreakpointMonitorResult>& OutFuture)
	{
		OutFuture = StartBreakpointMonitor(Port, bMonitorReady, bShouldStop, Config);

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Breakpoint monitor should become ready within the timeout"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}

	bool WaitForBreakpointAck(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client,
		TOptional<FAngelscriptBreakpoint>& OutBreakpoint)
	{
		const bool bReceivedAck = Session.PumpUntil(
			[&Client, &OutBreakpoint]()
			{
				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (!Envelope.IsSet() || Envelope->MessageType != EDebugMessageType::SetBreakpoint)
				{
					return false;
				}

				OutBreakpoint = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptBreakpoint>(Envelope.GetValue());
				return OutBreakpoint.IsSet();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!bReceivedAck)
		{
			Test.AddError(FString::Printf(TEXT("Timed out waiting for SetBreakpoint ack: %s"), *Client.GetLastError()));
		}

		return bReceivedAck;
	}

	bool WaitForBreakpointCount(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 ExpectedCount,
		const TCHAR* Context)
	{
		const bool bReachedCount = Session.PumpUntil(
			[&Session, ExpectedCount]()
			{
				return Session.GetDebugServer().BreakpointCount == ExpectedCount;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!bReachedCount)
		{
			Test.AddError(FString::Printf(TEXT("%s (actual breakpoint count: %d)."), Context, Session.GetDebugServer().BreakpointCount));
		}

		return bReachedCount;
	}

	bool WaitForSpecificBreakpoint(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const FString& ModuleKey,
		int32 ExpectedLine,
		const TCHAR* Context)
	{
		const bool bFoundBreakpoint = Session.PumpUntil(
			[&Session, &ModuleKey, ExpectedLine]()
			{
				const TSharedPtr<FAngelscriptDebugServer::FFileBreakpoints>* Active = Session.GetDebugServer().Breakpoints.Find(ModuleKey);
				return Active != nullptr && Active->IsValid() && (*Active)->Lines.Contains(ExpectedLine);
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bFoundBreakpoint);
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakpointProtocolTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointNearestExecutableLineAckTest,
	"Angelscript.TestModule.Debugger.Breakpoint.NearestExecutableLineAck",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointDuplicateSetReturnsRemovalAckTest,
	"Angelscript.TestModule.Debugger.Breakpoint.DuplicateSetReturnsRemovalAck",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerBreakpointNearestExecutableLineAckTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBreakpointFixture();
	TAtomic<bool> bMonitorShouldStop{false};
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	const int32 RequestedLine = Fixture.GetLine(TEXT("BreakpointHelperLine")) - 1;
	const int32 ExpectedLine = Fixture.GetLine(TEXT("BreakpointHelperLine"));
	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should target a non-executable line before the helper marker"), RequestedLine < ExpectedLine))
	{
		return false;
	}

	TAtomic<bool> bMonitorReady{false};
	FBreakpointMonitorConfig MonitorConfig;
	MonitorConfig.bRequestCallstack = true;
	MonitorConfig.bSendContinueOnStop = true;
	MonitorConfig.MaxStopsToHandle = 1;
	MonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FBreakpointMonitorResult> MonitorFuture;
	if (!StartAndWaitForMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MonitorConfig, MonitorFuture))
	{
		return false;
	}

	Client.DrainPendingMessages();

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = RequestedLine;
	Breakpoint.Id = 101;
	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should send the non-executable-line breakpoint request"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TOptional<FAngelscriptBreakpoint> BreakpointAck;
	if (!WaitForBreakpointAck(*this, Session, Client, BreakpointAck))
	{
		bMonitorShouldStop = true;
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should deserialize the SetBreakpoint ack payload"), BreakpointAck.IsSet()))
	{
		bMonitorShouldStop = true;
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should preserve the explicit breakpoint id in the ack"), BreakpointAck->Id, 101);
	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should keep the original fixture filename in the ack"), BreakpointAck->Filename, Fixture.Filename);
	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should snap the ack line to the nearest executable helper line"), BreakpointAck->LineNumber, ExpectedLine);

	if (!WaitForSpecificBreakpoint(
		*this,
		Session,
		Fixture.ModuleName.ToString(),
		ExpectedLine,
		TEXT("Debugger.Breakpoint.NearestExecutableLineAck should register the adjusted executable line on the server before running the script")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should keep exactly one authoritative breakpoint registered"), Session.GetDebugServer().BreakpointCount, 1);

	TSharedRef<FAsyncModuleInvocationState> InvocationState = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Breakpoint.NearestExecutableLineAck should complete script invocation after monitor sends Continue")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult MonitorResult = MonitorFuture.Get();

	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should stop exactly once after the adjusted breakpoint is hit"), MonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	const TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.StopEnvelopes[0]);
	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should deserialize the stop payload"), StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should stop because of a breakpoint"), StopMessage->Reason, FString(TEXT("breakpoint")));

	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should capture a callstack after the stop"), MonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should return at least one frame"), Callstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should report the fixture filename in the top stack frame"), Callstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should stop at the adjusted executable line"), Callstack.Frames[0].LineNumber, BreakpointAck->LineNumber);
	TestTrue(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should execute the script successfully after resume"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.NearestExecutableLineAck should preserve the script return value"), InvocationState->Result, 8);
	return !HasAnyErrors();
}

bool FAngelscriptDebuggerBreakpointDuplicateSetReturnsRemovalAckTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBreakpointFixture();
	TAtomic<bool> bMonitorShouldStop{false};
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	const int32 BreakpointLine = Fixture.GetLine(TEXT("BreakpointHelperLine"));

	TAtomic<bool> bMonitorReady{false};
	FBreakpointMonitorConfig MonitorConfig;
	MonitorConfig.bRequestCallstack = true;
	MonitorConfig.bSendContinueOnStop = true;
	MonitorConfig.MaxStopsToHandle = 1;
	MonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FBreakpointMonitorResult> MonitorFuture;
	if (!StartAndWaitForMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MonitorConfig, MonitorFuture))
	{
		return false;
	}

	Client.DrainPendingMessages();

	FAngelscriptBreakpoint InitialBreakpoint;
	InitialBreakpoint.Filename = Fixture.Filename;
	InitialBreakpoint.ModuleName = Fixture.ModuleName.ToString();
	InitialBreakpoint.LineNumber = BreakpointLine;
	InitialBreakpoint.Id = 201;
	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should send the initial breakpoint request"), Client.SendSetBreakpoint(InitialBreakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(
		*this,
		Session,
		1,
		TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should register exactly one breakpoint after the first request")))
	{
		return false;
	}

	if (!WaitForSpecificBreakpoint(
		*this,
		Session,
		Fixture.ModuleName.ToString(),
		BreakpointLine,
		TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should store the first breakpoint on the executable helper line")))
	{
		return false;
	}

	FAngelscriptBreakpoint DuplicateBreakpoint = InitialBreakpoint;
	DuplicateBreakpoint.Id = 202;
	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should send the duplicate breakpoint request"), Client.SendSetBreakpoint(DuplicateBreakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TOptional<FAngelscriptBreakpoint> DuplicateAck;
	if (!WaitForBreakpointAck(*this, Session, Client, DuplicateAck))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should deserialize the duplicate-breakpoint ack"), DuplicateAck.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should preserve the duplicate request id in the rejection ack"), DuplicateAck->Id, 202);
	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should preserve the original fixture filename in the rejection ack"), DuplicateAck->Filename, Fixture.Filename);
	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should ask the frontend to remove the duplicate breakpoint"), DuplicateAck->LineNumber, -1);

	if (!WaitForBreakpointCount(
		*this,
		Session,
		1,
		TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should keep the authoritative breakpoint count unchanged after a duplicate request")))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> InvocationState = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should complete script invocation after monitor sends Continue")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult MonitorResult = MonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should not report monitor-side transport errors"), MonitorResult.Error.IsEmpty()))
	{
		if (!MonitorResult.Error.IsEmpty())
		{
			AddError(MonitorResult.Error);
		}
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should not time out while waiting for the breakpoint hit"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should stop exactly once even after a duplicate request"), MonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	const TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.StopEnvelopes[0]);
	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should deserialize the stop payload"), StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should stop because of a breakpoint"), StopMessage->Reason, FString(TEXT("breakpoint")));

	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should capture a callstack after the stop"), MonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should return at least one frame"), Callstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should report the fixture filename in the top stack frame"), Callstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should stop at the helper line"), Callstack.Frames[0].LineNumber, BreakpointLine);
	TestTrue(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should execute the script successfully after resume"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.DuplicateSetReturnsRemovalAck should preserve the script return value"), InvocationState->Result, 8);
	return !HasAnyErrors();
}

#endif

