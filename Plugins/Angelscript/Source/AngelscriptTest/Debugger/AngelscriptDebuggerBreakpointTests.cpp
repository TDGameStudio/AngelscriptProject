#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"


#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakpointTests_Private
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

		if (!Test.TestTrue(TEXT("Debugger client should send StartDebugging before breakpoint tests"), bStartMessageSent))
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
		const FString& Declaration,
		const FString& DebugName)
	{
		TSharedRef<FAsyncModuleInvocationState> State = MakeShared<FAsyncModuleInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, DebugName, State]()
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

	// A second debug client on a background thread. PauseExecution blocks the
	// GameThread but its ProcessMessages() loop reads ALL client sockets, so the
	// monitor's Continue message unblocks the pause from the thread pool.
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

						if (Config.bRequestCallstack)
						{
							if (MonitorClient.SendRequestCallStack())
							{
								const double CallstackEnd = FPlatformTime::Seconds() + 10.0;
								while (FPlatformTime::Seconds() < CallstackEnd)
								{
									TOptional<FAngelscriptDebugMessageEnvelope> CsEnvelope = MonitorClient.ReceiveEnvelope();
									if (CsEnvelope.IsSet() && CsEnvelope->MessageType == EDebugMessageType::CallStack)
									{
										Result.CapturedCallstack = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptCallStack>(CsEnvelope.GetValue());
										break;
									}
									FPlatformProcess::Sleep(0.001f);
								}
							}
						}

						if (Config.bSendContinueOnStop)
						{
							MonitorClient.SendContinue();
						}

						StopsHandled++;
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
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakpointTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointHitLineTest,
	"Angelscript.TestModule.Debugger.Breakpoint.HitLine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointClearThenResumeTest,
	"Angelscript.TestModule.Debugger.Breakpoint.ClearThenResume",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointIgnoreInactiveBranchTest,
	"Angelscript.TestModule.Debugger.Breakpoint.IgnoreInactiveBranch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerBreakpointHitLineTest::RunTest(const FString& Parameters)
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

	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Fixture.Filename, Fixture.ModuleName.ToString());
	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should resolve the compiled module immediately after compilation"), ModuleDesc.IsValid() && ModuleDesc->ScriptModule != nullptr))
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

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointHelperLine"));
	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should send the target breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger.Breakpoint.HitLine should observe the breakpoint registration before running the script")))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> InvocationState = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Breakpoint.HitLine should complete script invocation after monitor sends Continue")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult MonitorResult = MonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should receive at least one HasStopped via the monitor"), MonitorResult.StopEnvelopes.Num() > 0))
	{
		if (!MonitorResult.Error.IsEmpty())
		{
			AddError(MonitorResult.Error);
		}
		return false;
	}

	const TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.StopEnvelopes[0]);
	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should deserialize the stop payload"), StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.HitLine should stop because of a breakpoint"), StopMessage->Reason, FString(TEXT("breakpoint")));

	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should capture a callstack via the monitor"), MonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Breakpoint.HitLine should return at least one frame"), Callstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.HitLine should report the fixture filename in the top stack frame"), Callstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Breakpoint.HitLine should stop at the requested helper line"), Callstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BreakpointHelperLine")));
	TestTrue(TEXT("Debugger.Breakpoint.HitLine should execute the script function successfully after resume"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.HitLine should keep the module function return value"), InvocationState->Result, 8);
	return !HasAnyErrors();
}

bool FAngelscriptDebuggerBreakpointClearThenResumeTest::RunTest(const FString& Parameters)
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

	if (!TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Fixture.Filename, Fixture.ModuleName.ToString());
	if (!TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should resolve the compiled module immediately after compilation"), ModuleDesc.IsValid() && ModuleDesc->ScriptModule != nullptr))
	{
		return false;
	}

	TAtomic<bool> bFirstMonitorReady{false};
	FBreakpointMonitorConfig FirstMonitorConfig;
	FirstMonitorConfig.bRequestCallstack = false;
	FirstMonitorConfig.bSendContinueOnStop = true;
	FirstMonitorConfig.MaxStopsToHandle = 1;
	FirstMonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FBreakpointMonitorResult> FirstMonitorFuture;
	if (!StartAndWaitForMonitorReady(*this, Session, Session.GetPort(), bFirstMonitorReady, bMonitorShouldStop, FirstMonitorConfig, FirstMonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointHelperLine"));
	if (!TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should send the target breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger.Breakpoint.ClearThenResume should observe the breakpoint registration before the first run")))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> FirstInvocation = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, FirstInvocation, TEXT("Debugger.Breakpoint.ClearThenResume should finish the first invocation after monitor sends Continue")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult FirstMonitorResult = FirstMonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should receive a stop event on the first invocation"), FirstMonitorResult.StopEnvelopes.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should finish the first invocation successfully"), FirstInvocation->bSucceeded);

	FAngelscriptClearBreakpoints ClearBreakpoints;
	ClearBreakpoints.Filename = Fixture.Filename;
	ClearBreakpoints.ModuleName = Fixture.ModuleName.ToString();
	if (!TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should clear the active breakpoints"), Client.SendClearBreakpoints(ClearBreakpoints)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 0, TEXT("Debugger.Breakpoint.ClearThenResume should observe the breakpoint removal before the second run")))
	{
		return false;
	}

	Client.DrainPendingMessages();

	bMonitorShouldStop = false;
	TAtomic<bool> bSecondMonitorReady{false};
	FBreakpointMonitorConfig SecondMonitorConfig;
	SecondMonitorConfig.bRequestCallstack = false;
	SecondMonitorConfig.bSendContinueOnStop = true;
	SecondMonitorConfig.MaxStopsToHandle = 1;
	SecondMonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FBreakpointMonitorResult> SecondMonitorFuture;
	if (!StartAndWaitForMonitorReady(*this, Session, Session.GetPort(), bSecondMonitorReady, bMonitorShouldStop, SecondMonitorConfig, SecondMonitorFuture))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> SecondInvocation = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, SecondInvocation, TEXT("Debugger.Breakpoint.ClearThenResume should complete the second invocation after breakpoints are cleared")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult SecondMonitorResult = SecondMonitorFuture.Get();

	TestEqual(TEXT("Cleared breakpoints should not stop the second invocation."), SecondMonitorResult.StopEnvelopes.Num(), 0);
	TestTrue(TEXT("Debugger.Breakpoint.ClearThenResume should still execute the script successfully after clearing breakpoints"), SecondInvocation->bSucceeded);

	return !HasAnyErrors();
}

bool FAngelscriptDebuggerBreakpointIgnoreInactiveBranchTest::RunTest(const FString& Parameters)
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

	if (!TestTrue(TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Fixture.Filename, Fixture.ModuleName.ToString());
	if (!TestTrue(TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should resolve the compiled module immediately after compilation"), ModuleDesc.IsValid() && ModuleDesc->ScriptModule != nullptr))
	{
		return false;
	}

	TAtomic<bool> bMonitorReady{false};
	FBreakpointMonitorConfig MonitorConfig;
	MonitorConfig.bRequestCallstack = false;
	MonitorConfig.bSendContinueOnStop = true;
	MonitorConfig.MaxStopsToHandle = 1;
	MonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FBreakpointMonitorResult> MonitorFuture;
	if (!StartAndWaitForMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MonitorConfig, MonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointInactiveBranchLine"));
	if (!TestTrue(TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should send the inactive-branch breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should observe the inactive-branch breakpoint registration before running the script")))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> InvocationState = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should complete script invocation")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FBreakpointMonitorResult MonitorResult = MonitorFuture.Get();

	TestEqual(TEXT("Breakpoint in the inactive branch should not have triggered a stop event."), MonitorResult.StopEnvelopes.Num(), 0);
	TestTrue(TEXT("Debugger.Breakpoint.IgnoreInactiveBranch should execute the function successfully when the inactive branch breakpoint never hits"), InvocationState->bSucceeded);

	return !HasAnyErrors();
}

#endif

