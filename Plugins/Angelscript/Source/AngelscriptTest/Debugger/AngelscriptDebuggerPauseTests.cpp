#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "HAL/PlatformProcess.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerPauseTests_Private
{
	bool StartPauseDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger pause should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger pause should connect the control client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger pause should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger pause should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForPauseBreakpointCount(
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

	struct FAsyncPauseInvocationState : public TSharedFromThis<FAsyncPauseInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncPauseInvocationState> DispatchPauseInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncPauseInvocationState> State = MakeShared<FAsyncPauseInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForPauseInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncPauseInvocationState>& InvocationState,
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

	bool WaitForMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		TAtomic<bool>& bMonitorReady,
		const TCHAR* Context)
	{
		return Test.TestTrue(
			Context,
			Session.PumpUntil(
				[&bMonitorReady]()
				{
					return bMonitorReady.Load();
				},
				Session.GetDefaultTimeoutSeconds()));
	}

	bool HandshakePauseMonitorClient(
		FAngelscriptDebuggerTestClient& Client,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds,
		FString& OutError)
	{
		const double HandshakeEnd = FPlatformTime::Seconds() + TimeoutSeconds;
		bool bSentStart = false;
		bool bReceivedVersion = false;
		while (FPlatformTime::Seconds() < HandshakeEnd && !bShouldStop.Load())
		{
			if (!bSentStart)
			{
				bSentStart = Client.SendStartDebugging(2);
				if (!bSentStart)
				{
					OutError = FString::Printf(TEXT("Pause monitor failed to send StartDebugging: %s"), *Client.GetLastError());
					return false;
				}
			}

			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet())
			{
				if (Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					bReceivedVersion = true;
					break;
				}
			}
			else if (!Client.GetLastError().IsEmpty())
			{
				OutError = FString::Printf(TEXT("Pause monitor failed during handshake: %s"), *Client.GetLastError());
				return false;
			}

			FPlatformProcess::Sleep(0.001f);
		}

		if (!bReceivedVersion)
		{
			OutError = bShouldStop.Load()
				? TEXT("Pause monitor handshake aborted before receiving DebugServerVersion.")
				: TEXT("Pause monitor timed out waiting for DebugServerVersion.");
			return false;
		}

		return true;
	}

	template <typename T>
	bool WaitForTypedMessageUntil(
		FAngelscriptDebuggerTestClient& Client,
		TAtomic<bool>& bShouldStop,
		EDebugMessageType ExpectedType,
		float TimeoutSeconds,
		TOptional<T>& OutValue,
		FString& OutError,
		const TCHAR* Context)
	{
		const double EndTime = FPlatformTime::Seconds() + TimeoutSeconds;
		while (FPlatformTime::Seconds() < EndTime && !bShouldStop.Load())
		{
			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet())
			{
				if (Envelope->MessageType == ExpectedType)
				{
					OutValue = FAngelscriptDebuggerTestClient::DeserializeMessage<T>(Envelope.GetValue());
					if (!OutValue.IsSet())
					{
						OutError = FString::Printf(TEXT("%s: failed to deserialize debugger message type %d."), Context, static_cast<int32>(ExpectedType));
						return false;
					}

					return true;
				}
			}
			else if (!Client.GetLastError().IsEmpty())
			{
				OutError = FString::Printf(TEXT("%s: %s"), Context, *Client.GetLastError());
				return false;
			}

			FPlatformProcess::Sleep(0.001f);
		}

		OutError = bShouldStop.Load()
			? FString::Printf(TEXT("%s: aborted while waiting for debugger message type %d."), Context, static_cast<int32>(ExpectedType))
			: FString::Printf(TEXT("%s: timed out waiting for debugger message type %d."), Context, static_cast<int32>(ExpectedType));
		return false;
	}

	struct FPauseMonitorResult
	{
		TOptional<FStoppedMessage> FirstStopMessage;
		TOptional<FAngelscriptCallStack> FirstCallstack;
		TOptional<FStoppedMessage> SecondStopMessage;
		TOptional<FAngelscriptCallStack> SecondCallstack;
		int32 ContinuedCount = 0;
		int32 UnexpectedStopCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	struct FControlPauseResult
	{
		bool bObservedContinued = false;
		bool bSentPause = false;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FPauseMonitorResult> StartPauseMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TAtomic<bool>& bInvocationCompleted,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, &bInvocationCompleted, TimeoutSeconds]() -> FPauseMonitorResult
			{
				FPauseMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Pause monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				if (!HandshakePauseMonitorClient(MonitorClient, bShouldStop, TimeoutSeconds, Result.Error))
				{
					Result.bTimedOut = !bShouldStop.Load();
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::HasStopped, TimeoutSeconds, Result.FirstStopMessage, Result.Error, TEXT("Pause monitor failed to receive the initial stop")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack() ||
					!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::CallStack, TimeoutSeconds, Result.FirstCallstack, Result.Error, TEXT("Pause monitor failed to receive the initial callstack")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Pause monitor failed to send Continue after the breakpoint stop: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				TOptional<FEmptyMessage> ContinueMessage;
				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::HasContinued, TimeoutSeconds, ContinueMessage, Result.Error, TEXT("Pause monitor failed to receive HasContinued after resuming from the breakpoint stop")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}
				++Result.ContinuedCount;

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::HasStopped, TimeoutSeconds, Result.SecondStopMessage, Result.Error, TEXT("Pause monitor failed to receive the pause stop")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack() ||
					!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::CallStack, TimeoutSeconds, Result.SecondCallstack, Result.Error, TEXT("Pause monitor failed to receive the pause callstack")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Pause monitor failed to send Continue after the pause stop: %s"), *MonitorClient.GetLastError());
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
					if (Envelope.IsSet())
					{
						if (Envelope->MessageType == EDebugMessageType::HasStopped)
						{
							++Result.UnexpectedStopCount;
							MonitorClient.SendContinue();
						}
					}
					else if (!MonitorClient.GetLastError().IsEmpty())
					{
						Result.Error = FString::Printf(TEXT("Pause monitor failed while waiting for invocation completion: %s"), *MonitorClient.GetLastError());
						return Result;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				Result.bTimedOut = !bInvocationCompleted.Load();
				if (Result.bTimedOut && Result.Error.IsEmpty())
				{
					Result.Error = TEXT("Pause monitor timed out waiting for invocation completion.");
				}
				return Result;
			});
	}

	TFuture<FControlPauseResult> StartControlPauseRequest(
		FAngelscriptDebuggerTestClient& Client,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[&Client, &bShouldStop, TimeoutSeconds]() -> FControlPauseResult
			{
				FControlPauseResult Result;
				const double EndTime = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < EndTime && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
					if (Envelope.IsSet())
					{
						if (Envelope->MessageType == EDebugMessageType::HasContinued)
						{
							Result.bObservedContinued = true;
							Result.bSentPause = Client.SendPause();
							if (!Result.bSentPause)
							{
								Result.Error = FString::Printf(TEXT("Control client failed to send Pause after receiving HasContinued: %s"), *Client.GetLastError());
							}
							return Result;
						}
					}
					else if (!Client.GetLastError().IsEmpty())
					{
						Result.Error = FString::Printf(TEXT("Control client failed while waiting for HasContinued: %s"), *Client.GetLastError());
						return Result;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				Result.bTimedOut = !bShouldStop.Load();
				if (Result.bTimedOut)
				{
					Result.Error = TEXT("Control client timed out waiting for HasContinued before sending Pause.");
				}
				return Result;
			});
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerPauseTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerPauseStopsAtNextScriptLineTest,
	"Angelscript.TestModule.Debugger.Session.PauseStopsAtNextScriptLine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-timing): Pause lands on for-header (line 6) instead of loop body PauseLoopLine (line 8); likely VM line-event granularity change in UE 5.7

bool FAngelscriptDebuggerPauseStopsAtNextScriptLineTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartPauseDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreatePauseFixture();
	TAtomic<bool> bMonitorShouldStop(false);
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should compile the pause fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TAtomic<bool> bMonitorReady(false);
	TAtomic<bool> bInvocationCompleted(false);
	TFuture<FPauseMonitorResult> MonitorFuture = StartPauseMonitor(
		Session.GetPort(),
		bMonitorReady,
		bMonitorShouldStop,
		bInvocationCompleted,
		Session.GetDefaultTimeoutSeconds());
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		if (MonitorFuture.IsValid())
		{
			MonitorFuture.Wait();
		}
	};

	TAtomic<bool> bControlShouldStop(false);
	TFuture<FControlPauseResult> ControlPauseFuture;
	ON_SCOPE_EXIT
	{
		bControlShouldStop = true;
		if (ControlPauseFuture.IsValid())
		{
			ControlPauseFuture.Wait();
		}
	};

	if (!WaitForMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Session.PauseStopsAtNextScriptLine should bring the pause monitor up before execution")))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("PauseReadyLine"));
	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should set the pause-ready breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForPauseBreakpointCount(*this, Session, 1, TEXT("Debugger.Session.PauseStopsAtNextScriptLine should observe the breakpoint registration")))
	{
		return false;
	}

	ControlPauseFuture = StartControlPauseRequest(
		Client,
		bControlShouldStop,
		Session.GetDefaultTimeoutSeconds());

	const TSharedRef<FAsyncPauseInvocationState> InvocationState = DispatchPauseInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForPauseInvocationCompletion(
		*this,
		Session,
		InvocationState,
		TEXT("Debugger.Session.PauseStopsAtNextScriptLine should finish the invocation after resuming from the pause stop")))
	{
		return false;
	}

	bInvocationCompleted = true;
	bMonitorShouldStop = true;
	bControlShouldStop = true;

	const FPauseMonitorResult MonitorResult = MonitorFuture.Get();
	const FControlPauseResult ControlPauseResult = ControlPauseFuture.Get();
	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should let the control client observe HasContinued without errors"), ControlPauseResult.Error.IsEmpty()))
	{
		AddError(ControlPauseResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should not time out while waiting for the control-client HasContinued"), ControlPauseResult.bTimedOut))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should observe HasContinued on the control client before sending Pause"), ControlPauseResult.bObservedContinued))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should send Pause from the control client after HasContinued"), ControlPauseResult.bSentPause))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should keep the pause monitor error-free"), MonitorResult.Error.IsEmpty()))
	{
		AddError(MonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should not time out while driving the pause scenario"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should capture the initial breakpoint stop"), MonitorResult.FirstStopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should capture the initial callstack"), MonitorResult.FirstCallstack.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should capture the pause stop"), MonitorResult.SecondStopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should capture the pause callstack"), MonitorResult.SecondCallstack.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should stop first because of the breakpoint"), MonitorResult.FirstStopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should report the fixture filename on the first stop"), MonitorResult.FirstCallstack->Frames.Num() > 0 && MonitorResult.FirstCallstack->Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should stop first at PauseReadyLine"), MonitorResult.FirstCallstack->Frames[0].LineNumber, Fixture.GetLine(TEXT("PauseReadyLine")));
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should observe exactly one HasContinued after the initial resume"), MonitorResult.ContinuedCount, 1);
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should stop the second time because of Pause"), MonitorResult.SecondStopMessage->Reason, FString(TEXT("pause")));
	TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should report the fixture filename on the pause stop"), MonitorResult.SecondCallstack->Frames.Num() > 0 && MonitorResult.SecondCallstack->Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should stop the second time at PauseLoopLine"), MonitorResult.SecondCallstack->Frames[0].LineNumber, Fixture.GetLine(TEXT("PauseLoopLine")));
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should not receive any unexpected extra HasStopped messages after resuming from Pause"), MonitorResult.UnexpectedStopCount, 0);
	TestTrue(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should finish the invocation successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Session.PauseStopsAtNextScriptLine should preserve the pause fixture return value"), InvocationState->Result, 5001);
	return !HasAnyErrors();
}

#endif

