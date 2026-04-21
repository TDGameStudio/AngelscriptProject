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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepOutEdgeTests_Private
{
	bool StartStepOutEdgeDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger StepOut edge test should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger StepOut edge test should connect the control client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger StepOut edge test should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger StepOut edge test should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForStepOutEdgeBreakpointCount(
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

	struct FAsyncStepOutEdgeInvocationState : public TSharedFromThis<FAsyncStepOutEdgeInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncStepOutEdgeInvocationState> DispatchStepOutEdgeInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncStepOutEdgeInvocationState> State = MakeShared<FAsyncStepOutEdgeInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForStepOutEdgeInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncStepOutEdgeInvocationState>& InvocationState,
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

	struct FStepOutTopFrameMonitorResult
	{
		TOptional<FAngelscriptDebugMessageEnvelope> InitialStopEnvelope;
		TOptional<FAngelscriptCallStack> InitialCallstack;
		int32 UnexpectedStopCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FStepOutTopFrameMonitorResult> StartActionThenExpectCompletionMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TAtomic<bool>& bInvocationCompleted,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, &bInvocationCompleted, TimeoutSeconds]() -> FStepOutTopFrameMonitorResult
			{
				FStepOutTopFrameMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("StepOut top-frame monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				const double HandshakeEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				bool bSentStart = false;
				bool bReceivedVersion = false;
				while (FPlatformTime::Seconds() < HandshakeEnd && !bShouldStop.Load())
				{
					if (!bSentStart)
					{
						bSentStart = MonitorClient.SendStartDebugging(2);
					}

					if (bSentStart)
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
					Result.Error = TEXT("StepOut top-frame monitor timed out waiting for DebugServerVersion.");
					Result.bTimedOut = true;
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				const double InitialStopEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < InitialStopEnd && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (!Envelope.IsSet())
					{
						FPlatformProcess::Sleep(0.001f);
						continue;
					}

					if (Envelope->MessageType == EDebugMessageType::HasStopped)
					{
						Result.InitialStopEnvelope = MoveTemp(Envelope);
						break;
					}
				}

				if (!Result.InitialStopEnvelope.IsSet())
				{
					Result.Error = TEXT("StepOut top-frame monitor timed out waiting for the initial HasStopped.");
					Result.bTimedOut = true;
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack())
				{
					Result.Error = FString::Printf(TEXT("StepOut top-frame monitor failed to request the initial callstack: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				const double CallstackEnd = FPlatformTime::Seconds() + 10.0;
				while (FPlatformTime::Seconds() < CallstackEnd && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::CallStack)
					{
						Result.InitialCallstack = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptCallStack>(Envelope.GetValue());
						break;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!Result.InitialCallstack.IsSet())
				{
					Result.Error = TEXT("StepOut top-frame monitor failed to receive the initial callstack.");
					return Result;
				}

				if (!MonitorClient.SendStepOut())
				{
					Result.Error = FString::Printf(TEXT("StepOut top-frame monitor failed to send StepOut: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				const double CompletionEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < CompletionEnd && !bShouldStop.Load())
				{
					if (bInvocationCompleted.Load())
					{
						return Result;
					}

					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (!Envelope.IsSet())
					{
						FPlatformProcess::Sleep(0.001f);
						continue;
					}

					if (Envelope->MessageType == EDebugMessageType::HasStopped)
					{
						++Result.UnexpectedStopCount;
						if (Result.Error.IsEmpty())
						{
							Result.Error = FString::Printf(TEXT("StepOut top-frame monitor received an unexpected HasStopped after StepOut (count: %d)."), Result.UnexpectedStopCount);
						}

						MonitorClient.SendContinue();
					}
				}

				Result.bTimedOut = !bInvocationCompleted.Load();
				if (Result.bTimedOut && Result.Error.IsEmpty())
				{
					Result.Error = TEXT("StepOut top-frame monitor timed out waiting for invocation completion.");
				}

				return Result;
			});
	}

	bool StartAndWaitForStepOutTopFrameMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TAtomic<bool>& bInvocationCompleted,
		TFuture<FStepOutTopFrameMonitorResult>& OutFuture)
	{
		OutFuture = StartActionThenExpectCompletionMonitor(
			Port,
			bMonitorReady,
			bShouldStop,
			bInvocationCompleted,
			Session.GetDefaultTimeoutSeconds());

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger StepOut edge test should bring the monitor up before execution"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepOutEdgeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerStepOutTopFrameCompletesTest,
	"Angelscript.TestModule.Debugger.Stepping.StepOutTopFrameCompletes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerStepOutTopFrameCompletesTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartStepOutEdgeDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateSteppingFixture();
	TAtomic<bool> bMonitorShouldStop{ false };
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TAtomic<bool> bInvocationCompleted{ false };
	TAtomic<bool> bMonitorReady{ false };
	TFuture<FStepOutTopFrameMonitorResult> MonitorFuture;
	if (!StartAndWaitForStepOutTopFrameMonitorReady(
		*this,
		Session,
		Session.GetPort(),
		bMonitorReady,
		bMonitorShouldStop,
		bInvocationCompleted,
		MonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepAfterCallLine"));
	if (!TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should set the top-frame breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForStepOutEdgeBreakpointCount(*this, Session, 1, TEXT("Stepping.StepOutTopFrameCompletes should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncStepOutEdgeInvocationState> InvocationState = DispatchStepOutEdgeInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForStepOutEdgeInvocationCompletion(
		*this,
		Session,
		InvocationState,
		TEXT("Stepping.StepOutTopFrameCompletes should finish after the top-frame StepOut")))
	{
		return false;
	}

	bInvocationCompleted = true;
	bMonitorShouldStop = true;

	const FStepOutTopFrameMonitorResult MonitorResult = MonitorFuture.Get();
	if (!TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should keep the completion monitor error-free"), MonitorResult.Error.IsEmpty()))
	{
		AddError(MonitorResult.Error);
	}

	if (!TestFalse(TEXT("Stepping.StepOutTopFrameCompletes should not time out while waiting for completion"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Stepping.StepOutTopFrameCompletes should not receive any extra HasStopped messages after StepOut"), MonitorResult.UnexpectedStopCount, 0))
	{
		return false;
	}

	const TOptional<FStoppedMessage> InitialStop = MonitorResult.InitialStopEnvelope.IsSet()
		? FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.InitialStopEnvelope.GetValue())
		: TOptional<FStoppedMessage>();
	if (!TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should deserialize the initial HasStopped payload"), InitialStop.IsSet()))
	{
		return false;
	}

	if (InitialStop.IsSet())
	{
		TestEqual(
			TEXT("Stepping.StepOutTopFrameCompletes should first stop because of the breakpoint"),
			InitialStop->Reason,
			FString(TEXT("breakpoint")));
	}

	if (!TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should receive the initial callstack"), MonitorResult.InitialCallstack.IsSet()))
	{
		return false;
	}

	if (MonitorResult.InitialCallstack.IsSet())
	{
		TestEqual(
			TEXT("Stepping.StepOutTopFrameCompletes should stop on the line after the call before issuing StepOut"),
			MonitorResult.InitialCallstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepAfterCallLine")));
		TestEqual(
			TEXT("Stepping.StepOutTopFrameCompletes should stay in the top frame when the breakpoint hits after the call"),
			MonitorResult.InitialCallstack->Frames.Num(),
			1);
	}

	TestTrue(TEXT("Stepping.StepOutTopFrameCompletes should execute successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Stepping.StepOutTopFrameCompletes should preserve the expected scenario result"), InvocationState->Result, 14);
	return !HasAnyErrors();
}

#endif

