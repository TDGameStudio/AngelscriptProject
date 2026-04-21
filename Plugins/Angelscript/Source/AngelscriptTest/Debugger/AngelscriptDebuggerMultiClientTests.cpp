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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerMultiClientTests_Private
{
	bool StartPrimaryDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger multi-client test should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger multi-client test should connect the primary debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger multi-client test should send StartDebugging for the primary client"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger multi-client test should receive DebugServerVersion for the primary client"), bReceivedVersion))
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
		return Test.TestTrue(
			Context,
			Session.PumpUntil(
				[&InvocationState]()
				{
					return InvocationState->bCompleted.Load();
				},
				Session.GetDefaultTimeoutSeconds()));
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
		return Test.TestTrue(
			Context,
			Session.PumpUntil(
				[&Session, &ModuleKey, ExpectedLine]()
				{
					const TSharedPtr<FAngelscriptDebugServer::FFileBreakpoints>* ActiveBreakpoints = Session.GetDebugServer().Breakpoints.Find(ModuleKey);
					return ActiveBreakpoints != nullptr && ActiveBreakpoints->IsValid() && (*ActiveBreakpoints)->Lines.Contains(ExpectedLine);
				},
				Session.GetDefaultTimeoutSeconds()));
	}

	struct FAdditionalDebuggerMonitorResult
	{
		TArray<FAngelscriptDebugMessageEnvelope> StopEnvelopes;
		TOptional<FStoppedMessage> StopMessage;
		TOptional<FAngelscriptCallStack> CapturedCallstack;
		int32 ContinuedCount = 0;
		bool bTimedOut = false;
		bool bCompletedWithoutStop = false;
		FString Error;
	};

	TFuture<FAdditionalDebuggerMonitorResult> StartAdditionalDebuggerClientMonitor(
		FAngelscriptDebugServer& DebugServer,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bHandshakeSucceeded,
		TAtomic<bool>& bAbortMonitor,
		TAtomic<bool>& bInvocationCompleted,
		TAtomic<int32>& OutMinObservedBreakpointCount,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[&DebugServer, Port, &bMonitorReady, &bHandshakeSucceeded, &bAbortMonitor, &bInvocationCompleted, &OutMinObservedBreakpointCount, TimeoutSeconds]() -> FAdditionalDebuggerMonitorResult
			{
				FAdditionalDebuggerMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Additional debugger client failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				const double HandshakeEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				bool bSentStartDebugging = false;
				while (FPlatformTime::Seconds() < HandshakeEnd && !bAbortMonitor.Load())
				{
					OutMinObservedBreakpointCount.Store(FMath::Min(OutMinObservedBreakpointCount.Load(), DebugServer.BreakpointCount));

					if (!bSentStartDebugging)
					{
						bSentStartDebugging = MonitorClient.SendStartDebugging(2);
						if (!bSentStartDebugging)
						{
							Result.Error = FString::Printf(TEXT("Additional debugger client failed to send StartDebugging: %s"), *MonitorClient.GetLastError());
							bMonitorReady = true;
							return Result;
						}
					}

					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
					{
						bHandshakeSucceeded = true;
						bMonitorReady = true;
						break;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!bHandshakeSucceeded.Load())
				{
					Result.Error = bAbortMonitor.Load()
						? TEXT("Additional debugger client monitor aborted before completing StartDebugging.")
						: FString::Printf(TEXT("Additional debugger client timed out waiting for DebugServerVersion after %.3f seconds."), TimeoutSeconds);
					Result.bTimedOut = !bAbortMonitor.Load();
					bMonitorReady = true;
					return Result;
				}

				const double MonitorEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < MonitorEnd && !bAbortMonitor.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (Envelope.IsSet())
					{
						if (Envelope->MessageType == EDebugMessageType::HasStopped)
						{
							Result.StopEnvelopes.Add(Envelope.GetValue());
							Result.StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(Envelope.GetValue());
							if (!Result.StopMessage.IsSet())
							{
								Result.Error = TEXT("Additional debugger client failed to deserialize the HasStopped payload.");
								return Result;
							}

							if (!MonitorClient.SendRequestCallStack())
							{
								Result.Error = FString::Printf(TEXT("Additional debugger client failed to request callstack: %s"), *MonitorClient.GetLastError());
								return Result;
							}

							Result.CapturedCallstack = MonitorClient.WaitForTypedMessage<FAngelscriptCallStack>(EDebugMessageType::CallStack, TimeoutSeconds);
							if (!Result.CapturedCallstack.IsSet())
							{
								Result.Error = FString::Printf(TEXT("Additional debugger client failed to receive callstack: %s"), *MonitorClient.GetLastError());
								Result.bTimedOut = true;
								return Result;
							}

							if (!MonitorClient.SendContinue())
							{
								Result.Error = FString::Printf(TEXT("Additional debugger client failed to send Continue: %s"), *MonitorClient.GetLastError());
								return Result;
							}

							const TOptional<FEmptyMessage> ContinuedMessage = MonitorClient.WaitForTypedMessage<FEmptyMessage>(EDebugMessageType::HasContinued, TimeoutSeconds);
							if (!ContinuedMessage.IsSet())
							{
								Result.Error = FString::Printf(TEXT("Additional debugger client failed to receive HasContinued: %s"), *MonitorClient.GetLastError());
								Result.bTimedOut = true;
								return Result;
							}

							Result.ContinuedCount = 1;
							return Result;
						}
					}
					else if (!MonitorClient.GetLastError().IsEmpty())
					{
						Result.Error = FString::Printf(TEXT("Additional debugger client monitor failed while waiting for HasStopped: %s"), *MonitorClient.GetLastError());
						return Result;
					}

					if (bInvocationCompleted.Load())
					{
						Result.bCompletedWithoutStop = true;
						return Result;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!bAbortMonitor.Load())
				{
					Result.bTimedOut = true;
					Result.Error = FString::Printf(TEXT("Additional debugger client monitor timed out after %.3f seconds waiting for HasStopped."), TimeoutSeconds);
				}

				return Result;
			});
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerMultiClientTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSecondClientStartPreservesBreakpointsTest,
	"Angelscript.TestModule.Debugger.Protocol.SecondClientStartPreservesBreakpoints",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSecondClientStartPreservesBreakpointsTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient PrimaryClient;
	if (!StartPrimaryDebuggerSession(*this, Session, PrimaryClient))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBreakpointFixture();
	TAtomic<bool> bAdditionalMonitorReady(false);
	TAtomic<bool> bAdditionalMonitorHandshakeSucceeded(false);
	TAtomic<bool> bAbortAdditionalMonitor(false);
	TAtomic<bool> bInvocationCompleted(false);
	TAtomic<int32> MinObservedBreakpointCountDuringSecondHandshake(MAX_int32);
	TFuture<FAdditionalDebuggerMonitorResult> AdditionalMonitorFuture;
	ON_SCOPE_EXIT
	{
		bAbortAdditionalMonitor = true;
		if (AdditionalMonitorFuture.IsValid())
		{
			AdditionalMonitorFuture.Wait();
		}

		PrimaryClient.SendStopDebugging();
		PrimaryClient.SendDisconnect();
		PrimaryClient.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger multi-client test should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	PrimaryClient.DrainPendingMessages();

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointHelperLine"));
	Breakpoint.Id = 421;
	if (!TestTrue(TEXT("Debugger multi-client test should register the primary breakpoint before connecting the second client"), PrimaryClient.SendSetBreakpoint(Breakpoint)))
	{
		AddError(PrimaryClient.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger multi-client test should observe one registered breakpoint before the second client starts debugging")))
	{
		return false;
	}

	if (!WaitForSpecificBreakpoint(
			*this,
			Session,
			Fixture.ModuleName.ToString(),
			Fixture.GetLine(TEXT("BreakpointHelperLine")),
			TEXT("Debugger multi-client test should store the helper-line breakpoint before the second client starts debugging")))
	{
		return false;
	}

	AdditionalMonitorFuture = StartAdditionalDebuggerClientMonitor(
		Session.GetDebugServer(),
		Session.GetPort(),
		bAdditionalMonitorReady,
		bAdditionalMonitorHandshakeSucceeded,
		bAbortAdditionalMonitor,
		bInvocationCompleted,
		MinObservedBreakpointCountDuringSecondHandshake,
		Session.GetDefaultTimeoutSeconds());

	const bool bAdditionalMonitorReadyReached = Session.PumpUntil(
		[&bAdditionalMonitorReady]()
		{
			return bAdditionalMonitorReady.Load();
		},
		Session.GetDefaultTimeoutSeconds());
	if (!TestTrue(TEXT("Debugger multi-client test should bring the additional debugger client to the post-StartDebugging ready state"), bAdditionalMonitorReadyReached))
	{
		return false;
	}

	if (!bAdditionalMonitorHandshakeSucceeded.Load())
	{
		const FAdditionalDebuggerMonitorResult MonitorResult = AdditionalMonitorFuture.Get();
		if (!MonitorResult.Error.IsEmpty())
		{
			AddError(MonitorResult.Error);
		}
		return false;
	}

	TestEqual(
		TEXT("Debugger multi-client test should not let breakpoint count dip during the second client StartDebugging handshake"),
		MinObservedBreakpointCountDuringSecondHandshake.Load(),
		1);

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger multi-client test should preserve the authoritative breakpoint count after the second client starts debugging")))
	{
		return false;
	}

	if (!WaitForSpecificBreakpoint(
			*this,
			Session,
			Fixture.ModuleName.ToString(),
			Fixture.GetLine(TEXT("BreakpointHelperLine")),
			TEXT("Debugger multi-client test should keep the helper-line breakpoint registered after the second client starts debugging")))
	{
		return false;
	}

	TSharedRef<FAsyncModuleInvocationState> InvocationState = DispatchModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger multi-client test should complete the invocation after continuing from the preserved breakpoint stop")))
	{
		return false;
	}
	bInvocationCompleted = true;

	const FAdditionalDebuggerMonitorResult MonitorResult = AdditionalMonitorFuture.Get();
	if (!TestTrue(TEXT("Debugger multi-client test should complete the additional-client monitor without transport errors"), MonitorResult.Error.IsEmpty()))
	{
		if (!MonitorResult.Error.IsEmpty())
		{
			AddError(MonitorResult.Error);
		}
		return false;
	}

	if (!TestFalse(TEXT("Debugger multi-client test should not time out while waiting for the preserved breakpoint stop"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestFalse(TEXT("Debugger multi-client test should not complete the invocation before any additional client observes the preserved breakpoint stop"), MonitorResult.bCompletedWithoutStop))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger multi-client test should emit exactly one preserved breakpoint stop for the additional debugger client"), MonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger multi-client test should deserialize the preserved HasStopped payload"), MonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger multi-client test should stop because of a breakpoint"), MonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));

	if (!TestTrue(TEXT("Debugger multi-client test should capture a callstack from the additional debugger client after the preserved breakpoint stop"), MonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger multi-client test should return at least one frame after the preserved breakpoint stop"), Callstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger multi-client test should report the fixture filename in the top stack frame"), Callstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger multi-client test should stop at BreakpointHelperLine"), Callstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BreakpointHelperLine")));
	TestEqual(TEXT("Debugger multi-client test should observe a single HasContinued after the preserved breakpoint stop"), MonitorResult.ContinuedCount, 1);

	TestTrue(TEXT("Debugger multi-client test should execute the breakpoint fixture successfully after continue"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger multi-client test should preserve the fixture return value"), InvocationState->Result, 8);
	return !HasAnyErrors();
}

#endif

