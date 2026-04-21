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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepInStatementTests_Private
{
	bool StartStepInOnStatementDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger StepIn-on-statement test should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger StepIn-on-statement test should connect the control client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger StepIn-on-statement test should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger StepIn-on-statement test should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForStepInOnStatementBreakpointCount(
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

	struct FAsyncStepInOnStatementInvocationState : public TSharedFromThis<FAsyncStepInOnStatementInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncStepInOnStatementInvocationState> DispatchStepInOnStatementInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncStepInOnStatementInvocationState> State = MakeShared<FAsyncStepInOnStatementInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForStepInOnStatementInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncStepInOnStatementInvocationState>& InvocationState,
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

	enum class EStepInOnStatementAction : uint8
	{
		Continue,
		StepIn,
	};

	struct FStepInOnStatementPhase
	{
		EStepInOnStatementAction Action = EStepInOnStatementAction::Continue;
		bool bRequestCallstack = true;
	};

	struct FStepInOnStatementStop
	{
		FAngelscriptDebugMessageEnvelope StopEnvelope;
		TOptional<FAngelscriptCallStack> Callstack;
	};

	struct FStepInOnStatementMonitorResult
	{
		TArray<FStepInOnStatementStop> Stops;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FStepInOnStatementMonitorResult> StartStepInOnStatementMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepInOnStatementPhase> Phases,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Phases = MoveTemp(Phases), TimeoutSeconds]() -> FStepInOnStatementMonitorResult
			{
				FStepInOnStatementMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("StepIn-on-statement monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
					Result.Error = TEXT("StepIn-on-statement monitor timed out waiting for DebugServerVersion.");
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
						Result.Error = FString::Printf(TEXT("StepIn-on-statement monitor received unexpected stop #%d beyond configured phases."), StopsHandled + 1);
						break;
					}

					FStepInOnStatementStop Stop;
					Stop.StopEnvelope = Envelope.GetValue();

					const FStepInOnStatementPhase& Phase = Phases[StopsHandled];
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
					case EStepInOnStatementAction::Continue:
						MonitorClient.SendContinue();
						break;
					case EStepInOnStatementAction::StepIn:
						MonitorClient.SendStepIn();
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

	bool StartAndWaitForStepInOnStatementMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepInOnStatementPhase> Phases,
		TFuture<FStepInOnStatementMonitorResult>& OutFuture)
	{
		OutFuture = StartStepInOnStatementMonitor(Port, bMonitorReady, bShouldStop, MoveTemp(Phases), Session.GetDefaultTimeoutSeconds());

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger StepIn-on-statement test should bring the step monitor up before execution"), bReady))
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

		const FString FrameContext = FString::Printf(TEXT("%s should include frame %d"), Context, FrameIndex);
		if (!Test.TestTrue(*FrameContext, Callstack->Frames.IsValidIndex(FrameIndex)))
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

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerStepInStatementTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerStepInOnStatementAdvancesWithinFrameTest,
	"Angelscript.TestModule.Debugger.Stepping.StepInOnStatementAdvancesWithinFrame",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerStepInOnStatementAdvancesWithinFrameTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartStepInOnStatementDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateSteppingFixture();
	TAtomic<bool> bMonitorShouldStop{ false };
	TFuture<FStepInOnStatementMonitorResult> MonitorFuture;
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

	if (!TestTrue(TEXT("Debugger StepIn-on-statement test should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FStepInOnStatementPhase> Phases;
	Phases.Add({ EStepInOnStatementAction::StepIn, true });
	Phases.Add({ EStepInOnStatementAction::Continue, true });

	TAtomic<bool> bMonitorReady{ false };
	if (!StartAndWaitForStepInOnStatementMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}
	bMonitorStarted = true;

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepInnerEntryLine"));
	if (!TestTrue(TEXT("Debugger StepIn-on-statement test should set the callee breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForStepInOnStatementBreakpointCount(*this, Session, 1, TEXT("Debugger StepIn-on-statement test should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncStepInOnStatementInvocationState> InvocationState = DispatchStepInOnStatementInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForStepInOnStatementInvocationCompletion(
		*this,
		Session,
		InvocationState,
		TEXT("Debugger StepIn-on-statement test should finish after the monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	const FStepInOnStatementMonitorResult MonitorResult = MonitorFuture.Get();
	bMonitorResultConsumed = true;
	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	TestFalse(TEXT("Debugger StepIn-on-statement monitor should not time out"), MonitorResult.bTimedOut);
	if (!TestEqual(TEXT("Debugger StepIn-on-statement test should emit exactly 2 stops"), MonitorResult.Stops.Num(), 2))
	{
		return false;
	}

	AssertStopReason(*this, MonitorResult.Stops[0].StopEnvelope, TEXT("breakpoint"), TEXT("Debugger StepIn-on-statement first stop"));
	AssertStopReason(*this, MonitorResult.Stops[1].StopEnvelope, TEXT("step"), TEXT("Debugger StepIn-on-statement second stop"));

	const int32 StepInnerEntryLine = Fixture.GetLine(TEXT("StepInnerEntryLine"));
	const int32 StepInnerLine = Fixture.GetLine(TEXT("StepInnerLine"));
	const int32 StepCallLine = Fixture.GetLine(TEXT("StepCallLine"));
	const int32 StepAfterCallLine = Fixture.GetLine(TEXT("StepAfterCallLine"));

	if (AssertFrameMatches(
		*this,
		MonitorResult.Stops[0].Callstack,
		0,
		Fixture.Filename,
		StepInnerEntryLine,
		TEXT("Debugger StepIn-on-statement first stop top frame")))
	{
		TestEqual(
			TEXT("Debugger StepIn-on-statement first stop should expose caller and callee frames"),
			MonitorResult.Stops[0].Callstack->Frames.Num(),
			2);
		AssertFrameMatches(
			*this,
			MonitorResult.Stops[0].Callstack,
			1,
			Fixture.Filename,
			StepCallLine,
			TEXT("Debugger StepIn-on-statement first stop caller frame"));
	}

	if (AssertFrameMatches(
		*this,
		MonitorResult.Stops[1].Callstack,
		0,
		Fixture.Filename,
		StepInnerLine,
		TEXT("Debugger StepIn-on-statement second stop top frame")))
	{
		TestEqual(
			TEXT("Debugger StepIn-on-statement second stop should stay inside the same frame depth"),
			MonitorResult.Stops[1].Callstack->Frames.Num(),
			2);
		AssertFrameMatches(
			*this,
			MonitorResult.Stops[1].Callstack,
			1,
			Fixture.Filename,
			StepCallLine,
			TEXT("Debugger StepIn-on-statement second stop caller frame"));
		TestTrue(
			TEXT("Debugger StepIn-on-statement second stop should advance beyond the entry line"),
			MonitorResult.Stops[1].Callstack->Frames[0].LineNumber != StepInnerEntryLine);
		TestTrue(
			TEXT("Debugger StepIn-on-statement second stop should not jump to the after-call line"),
			MonitorResult.Stops[1].Callstack->Frames[0].LineNumber != StepAfterCallLine);
	}

	TestTrue(TEXT("Debugger StepIn-on-statement test should execute successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger StepIn-on-statement test should preserve the stepping fixture result"), InvocationState->Result, 14);
	return !HasAnyErrors();
}

#endif

