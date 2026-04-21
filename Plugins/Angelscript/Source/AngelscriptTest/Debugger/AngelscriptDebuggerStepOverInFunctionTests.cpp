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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepOverInFunctionTests_Private
{
	bool StartStepOverWithinCalleeDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger StepOver-within-callee test should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger StepOver-within-callee test should connect the control client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger StepOver-within-callee test should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger StepOver-within-callee test should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForStepOverWithinCalleeBreakpointCount(
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

	struct FAsyncStepOverWithinCalleeInvocationState : public TSharedFromThis<FAsyncStepOverWithinCalleeInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncStepOverWithinCalleeInvocationState> DispatchStepOverWithinCalleeInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncStepOverWithinCalleeInvocationState> State = MakeShared<FAsyncStepOverWithinCalleeInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForStepOverWithinCalleeInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncStepOverWithinCalleeInvocationState>& InvocationState,
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

	enum class EStepOverWithinCalleeAction : uint8
	{
		Continue,
		StepIn,
		StepOver,
	};

	struct FStepOverWithinCalleePhase
	{
		EStepOverWithinCalleeAction Action = EStepOverWithinCalleeAction::Continue;
		bool bRequestCallstack = true;
	};

	struct FStepOverWithinCalleeStop
	{
		FAngelscriptDebugMessageEnvelope StopEnvelope;
		TOptional<FAngelscriptCallStack> Callstack;
	};

	struct FStepOverWithinCalleeMonitorResult
	{
		TArray<FStepOverWithinCalleeStop> Stops;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FStepOverWithinCalleeMonitorResult> StartStepOverWithinCalleeMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepOverWithinCalleePhase> Phases,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Phases = MoveTemp(Phases), TimeoutSeconds]() -> FStepOverWithinCalleeMonitorResult
			{
				FStepOverWithinCalleeMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("StepOver-within-callee monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

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
					Result.Error = TEXT("StepOver-within-callee monitor timed out waiting for DebugServerVersion.");
					Result.bTimedOut = true;
					bMonitorReady = true;
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
					return Result;
				}

				bMonitorReady = true;

				int32 StopsHandled = 0;
				const double MonitorEnd = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < MonitorEnd && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (!Envelope.IsSet())
					{
						FPlatformProcess::Sleep(0.001f);
						continue;
					}

					if (Envelope->MessageType != EDebugMessageType::HasStopped)
					{
						continue;
					}

					if (StopsHandled >= Phases.Num())
					{
						MonitorClient.SendContinue();
						Result.Error = FString::Printf(TEXT("StepOver-within-callee monitor received unexpected stop #%d beyond configured phases."), StopsHandled + 1);
						break;
					}

					FStepOverWithinCalleeStop Stop;
					Stop.StopEnvelope = Envelope.GetValue();

					const FStepOverWithinCalleePhase& Phase = Phases[StopsHandled];
					if (Phase.bRequestCallstack && MonitorClient.SendRequestCallStack())
					{
						const double CallstackEnd = FPlatformTime::Seconds() + 10.0;
						while (FPlatformTime::Seconds() < CallstackEnd)
						{
							TOptional<FAngelscriptDebugMessageEnvelope> CallstackEnvelope = MonitorClient.ReceiveEnvelope();
							if (CallstackEnvelope.IsSet() && CallstackEnvelope->MessageType == EDebugMessageType::CallStack)
							{
								Stop.Callstack = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptCallStack>(CallstackEnvelope.GetValue());
								break;
							}

							FPlatformProcess::Sleep(0.001f);
						}
					}

					Result.Stops.Add(MoveTemp(Stop));

					switch (Phase.Action)
					{
					case EStepOverWithinCalleeAction::Continue:
						MonitorClient.SendContinue();
						break;
					case EStepOverWithinCalleeAction::StepIn:
						MonitorClient.SendStepIn();
						break;
					case EStepOverWithinCalleeAction::StepOver:
						MonitorClient.SendStepOver();
						break;
					}

					++StopsHandled;
					if (StopsHandled >= Phases.Num())
					{
						break;
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

	bool StartAndWaitForStepOverWithinCalleeMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepOverWithinCalleePhase> Phases,
		TFuture<FStepOverWithinCalleeMonitorResult>& OutFuture)
	{
		OutFuture = StartStepOverWithinCalleeMonitor(Port, bMonitorReady, bShouldStop, MoveTemp(Phases), Session.GetDefaultTimeoutSeconds());

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger StepOver-within-callee test should bring the step monitor up before execution"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}

	bool AssertStopReason(
		FAutomationTestBase& Test,
		const FAngelscriptDebugMessageEnvelope& Envelope,
		const FString& ExpectedReason,
		const TCHAR* Context)
	{
		const TOptional<FStoppedMessage> StoppedMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(Envelope);
		const FString DeserializeContext = FString::Printf(TEXT("%s should deserialize into a stopped message"), Context);
		if (!Test.TestTrue(*DeserializeContext, StoppedMessage.IsSet()))
		{
			return false;
		}

		const FString ReasonContext = FString::Printf(TEXT("%s should report the expected stop reason"), Context);
		return Test.TestEqual(*ReasonContext, StoppedMessage->Reason, ExpectedReason);
	}

	bool AssertFrameMatches(
		FAutomationTestBase& Test,
		const TOptional<FAngelscriptCallStack>& Callstack,
		int32 FrameIndex,
		const FString& ExpectedFilename,
		int32 ExpectedLine,
		const TCHAR* Context)
	{
		const FString CallstackContext = FString::Printf(TEXT("%s should include a callstack"), Context);
		if (!Test.TestTrue(*CallstackContext, Callstack.IsSet()))
		{
			return false;
		}

		const FString FrameCountContext = FString::Printf(TEXT("%s should include frame %d"), Context, FrameIndex);
		if (!Test.TestTrue(*FrameCountContext, Callstack->Frames.IsValidIndex(FrameIndex)))
		{
			return false;
		}

		const FAngelscriptCallFrame& Frame = Callstack->Frames[FrameIndex];
		bool bPassed = true;
		const FString SourceContext = FString::Printf(TEXT("%s should stay on the expected source file"), Context);
		bPassed &= Test.TestEqual(*SourceContext, FPaths::GetCleanFilename(Frame.Source), ExpectedFilename);
		const FString LineContext = FString::Printf(TEXT("%s should report the expected line"), Context);
		bPassed &= Test.TestEqual(*LineContext, Frame.LineNumber, ExpectedLine);
		return bPassed;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepOverInFunctionTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerStepOverWithinCalleeTest,
	"Angelscript.TestModule.Debugger.Stepping.StepOverWithinCallee",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerStepOverWithinCalleeTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartStepOverWithinCalleeDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateSteppingFixture();
	TAtomic<bool> bMonitorShouldStop{ false };
	TFuture<FStepOverWithinCalleeMonitorResult> MonitorFuture;
	bool bMonitorStarted = false;
	bool bMonitorResultConsumed = false;
	ON_SCOPE_EXIT
	{
		bMonitorShouldStop = true;
		if (bMonitorStarted && MonitorFuture.IsValid() && !bMonitorResultConsumed)
		{
			MonitorFuture.Wait();
		}

		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger StepOver-within-callee test should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FStepOverWithinCalleePhase> Phases;
	Phases.Add({ EStepOverWithinCalleeAction::StepIn, true });
	Phases.Add({ EStepOverWithinCalleeAction::StepOver, true });
	Phases.Add({ EStepOverWithinCalleeAction::Continue, true });

	TAtomic<bool> bMonitorReady{ false };
	if (!StartAndWaitForStepOverWithinCalleeMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}
	bMonitorStarted = true;

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Debugger StepOver-within-callee test should set the caller breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForStepOverWithinCalleeBreakpointCount(*this, Session, 1, TEXT("Debugger StepOver-within-callee test should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncStepOverWithinCalleeInvocationState> InvocationState = DispatchStepOverWithinCalleeInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForStepOverWithinCalleeInvocationCompletion(
		*this,
		Session,
		InvocationState,
		TEXT("Debugger StepOver-within-callee test should finish after the monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	const FStepOverWithinCalleeMonitorResult MonitorResult = MonitorFuture.Get();
	bMonitorResultConsumed = true;
	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	TestFalse(TEXT("Debugger StepOver-within-callee monitor should not time out"), MonitorResult.bTimedOut);
	if (!TestEqual(TEXT("Debugger StepOver-within-callee test should emit exactly 3 stops"), MonitorResult.Stops.Num(), 3))
	{
		return false;
	}

	AssertStopReason(*this, MonitorResult.Stops[0].StopEnvelope, TEXT("breakpoint"), TEXT("Debugger StepOver-within-callee first stop"));
	AssertStopReason(*this, MonitorResult.Stops[1].StopEnvelope, TEXT("step"), TEXT("Debugger StepOver-within-callee second stop"));
	AssertStopReason(*this, MonitorResult.Stops[2].StopEnvelope, TEXT("step"), TEXT("Debugger StepOver-within-callee third stop"));

	if (AssertFrameMatches(
		*this,
		MonitorResult.Stops[0].Callstack,
		0,
		Fixture.Filename,
		Fixture.GetLine(TEXT("StepCallLine")),
		TEXT("Debugger StepOver-within-callee first stop top frame")))
	{
		TestEqual(
			TEXT("Debugger StepOver-within-callee first stop should stay at caller depth"),
			MonitorResult.Stops[0].Callstack->Frames.Num(),
			1);
	}

	if (AssertFrameMatches(
		*this,
		MonitorResult.Stops[1].Callstack,
		0,
		Fixture.Filename,
		Fixture.GetLine(TEXT("StepInnerEntryLine")),
		TEXT("Debugger StepOver-within-callee second stop top frame")))
	{
		TestEqual(
			TEXT("Debugger StepOver-within-callee second stop should expose caller and callee frames"),
			MonitorResult.Stops[1].Callstack->Frames.Num(),
			2);
		AssertFrameMatches(
			*this,
			MonitorResult.Stops[1].Callstack,
			1,
			Fixture.Filename,
			Fixture.GetLine(TEXT("StepCallLine")),
			TEXT("Debugger StepOver-within-callee second stop caller frame"));
	}

	if (AssertFrameMatches(
		*this,
		MonitorResult.Stops[2].Callstack,
		0,
		Fixture.Filename,
		Fixture.GetLine(TEXT("StepInnerLine")),
		TEXT("Debugger StepOver-within-callee third stop top frame")))
	{
		TestEqual(
			TEXT("Debugger StepOver-within-callee third stop should stay inside the callee"),
			MonitorResult.Stops[2].Callstack->Frames.Num(),
			2);
		AssertFrameMatches(
			*this,
			MonitorResult.Stops[2].Callstack,
			1,
			Fixture.Filename,
			Fixture.GetLine(TEXT("StepCallLine")),
			TEXT("Debugger StepOver-within-callee third stop caller frame"));
		TestTrue(
			TEXT("Debugger StepOver-within-callee third stop should not jump to the after-call line"),
			MonitorResult.Stops[2].Callstack->Frames[0].LineNumber != Fixture.GetLine(TEXT("StepAfterCallLine")));
	}

	TestTrue(TEXT("Debugger StepOver-within-callee test should execute successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger StepOver-within-callee test should preserve the stepping fixture result"), InvocationState->Result, 14);
	return !HasAnyErrors();
}

#endif

