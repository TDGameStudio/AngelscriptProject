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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerSteppingTests_Private
{
	bool StartSteppingDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger stepping should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger stepping should connect the test client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger stepping should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger stepping should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForSteppingBreakpointCount(
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

	struct FAsyncSteppingInvocationState : public TSharedFromThis<FAsyncSteppingInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncSteppingInvocationState> DispatchSteppingModuleInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncSteppingInvocationState> State = MakeShared<FAsyncSteppingInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForSteppingInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncSteppingInvocationState>& InvocationState,
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

	enum class EStepMonitorAction : uint8
	{
		Continue,
		StepIn,
		StepOver,
		StepOut,
	};

	struct FStepMonitorPhase
	{
		EStepMonitorAction Action = EStepMonitorAction::Continue;
		bool bRequestCallstack = true;
	};

	struct FStepMonitorStop
	{
		FAngelscriptDebugMessageEnvelope StopEnvelope;
		TOptional<FAngelscriptCallStack> Callstack;
	};

	struct FStepMonitorResult
	{
		TArray<FStepMonitorStop> Stops;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FStepMonitorResult> StartStepMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepMonitorPhase> Phases,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Phases = MoveTemp(Phases), TimeoutSeconds]() -> FStepMonitorResult
			{
				FStepMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Step monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
					Result.Error = TEXT("Step monitor timed out waiting for DebugServerVersion.");
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
						Result.Error = FString::Printf(TEXT("Received unexpected stop #%d beyond configured phases."), StopsHandled + 1);
						break;
					}

					FStepMonitorStop Stop;
					Stop.StopEnvelope = Envelope.GetValue();

					const FStepMonitorPhase& Phase = Phases[StopsHandled];
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
					case EStepMonitorAction::Continue:
						MonitorClient.SendContinue();
						break;
					case EStepMonitorAction::StepIn:
						MonitorClient.SendStepIn();
						break;
					case EStepMonitorAction::StepOver:
						MonitorClient.SendStepOver();
						break;
					case EStepMonitorAction::StepOut:
						MonitorClient.SendStepOut();
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

	bool StartAndWaitForStepMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FStepMonitorPhase> Phases,
		TFuture<FStepMonitorResult>& OutFuture)
	{
		OutFuture = StartStepMonitor(Port, bMonitorReady, bShouldStop, MoveTemp(Phases), Session.GetDefaultTimeoutSeconds());

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger stepping should bring the step monitor up before execution"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerSteppingTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSteppingStepInTest,
	"Angelscript.TestModule.Debugger.Stepping.StepIn",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSteppingStepOverTest,
	"Angelscript.TestModule.Debugger.Stepping.StepOver",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSteppingStepOutTest,
	"Angelscript.TestModule.Debugger.Stepping.StepOut",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSteppingStepInTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartSteppingDebuggerSession(*this, Session, Client))
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

	if (!TestTrue(TEXT("Stepping.StepIn should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FStepMonitorPhase> Phases;
	Phases.Add({ EStepMonitorAction::StepIn, true });
	Phases.Add({ EStepMonitorAction::Continue, true });

	TAtomic<bool> bMonitorReady{ false };
	TFuture<FStepMonitorResult> MonitorFuture;
	if (!StartAndWaitForStepMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Stepping.StepIn should set the call-site breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForSteppingBreakpointCount(*this, Session, 1, TEXT("Stepping.StepIn should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncSteppingInvocationState> InvocationState = DispatchSteppingModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForSteppingInvocationCompletion(*this, Session, InvocationState, TEXT("Stepping.StepIn should finish after monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	const FStepMonitorResult MonitorResult = MonitorFuture.Get();
	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	if (!TestEqual(TEXT("Stepping.StepIn should emit exactly 2 stops"), MonitorResult.Stops.Num(), 2))
	{
		return false;
	}

	const TOptional<FStoppedMessage> FirstStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[0].StopEnvelope);
	const TOptional<FStoppedMessage> SecondStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[1].StopEnvelope);
	TestTrue(TEXT("Stepping.StepIn first stop should deserialize"), FirstStop.IsSet());
	TestTrue(TEXT("Stepping.StepIn second stop should deserialize"), SecondStop.IsSet());
	if (FirstStop.IsSet())
	{
		TestEqual(TEXT("Stepping.StepIn first stop should be a breakpoint"), FirstStop->Reason, FString(TEXT("breakpoint")));
	}
	if (SecondStop.IsSet())
	{
		TestEqual(TEXT("Stepping.StepIn second stop should be a step"), SecondStop->Reason, FString(TEXT("step")));
	}

	if (TestTrue(TEXT("Stepping.StepIn first stop should have a callstack"), MonitorResult.Stops[0].Callstack.IsSet()))
	{
		TestEqual(TEXT("Stepping.StepIn should first stop at the call line"),
			MonitorResult.Stops[0].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepCallLine")));
	}

	if (TestTrue(TEXT("Stepping.StepIn second stop should have a callstack"), MonitorResult.Stops[1].Callstack.IsSet()))
	{
		TestTrue(TEXT("Stepping.StepIn should enter the callee frame"), MonitorResult.Stops[1].Callstack->Frames.Num() >= 2);
		TestEqual(TEXT("Stepping.StepIn should land inside Inner()"),
			MonitorResult.Stops[1].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepInnerEntryLine")));
	}

	TestTrue(TEXT("Stepping.StepIn should execute successfully"), InvocationState->bSucceeded);
	return !HasAnyErrors();
}

bool FAngelscriptDebuggerSteppingStepOverTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartSteppingDebuggerSession(*this, Session, Client))
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

	if (!TestTrue(TEXT("Stepping.StepOver should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FStepMonitorPhase> Phases;
	Phases.Add({ EStepMonitorAction::StepOver, true });
	Phases.Add({ EStepMonitorAction::Continue, true });

	TAtomic<bool> bMonitorReady{ false };
	TFuture<FStepMonitorResult> MonitorFuture;
	if (!StartAndWaitForStepMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Stepping.StepOver should set the call-site breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForSteppingBreakpointCount(*this, Session, 1, TEXT("Stepping.StepOver should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncSteppingInvocationState> InvocationState = DispatchSteppingModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForSteppingInvocationCompletion(*this, Session, InvocationState, TEXT("Stepping.StepOver should finish after monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	const FStepMonitorResult MonitorResult = MonitorFuture.Get();
	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	if (!TestEqual(TEXT("Stepping.StepOver should emit exactly 2 stops"), MonitorResult.Stops.Num(), 2))
	{
		return false;
	}

	if (TestTrue(TEXT("Stepping.StepOver first stop should have a callstack"), MonitorResult.Stops[0].Callstack.IsSet()))
	{
		TestEqual(TEXT("Stepping.StepOver should first stop at the call line"),
			MonitorResult.Stops[0].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepCallLine")));
	}

	if (TestTrue(TEXT("Stepping.StepOver second stop should have a callstack"), MonitorResult.Stops[1].Callstack.IsSet()))
	{
		TestEqual(TEXT("Stepping.StepOver should land at the line after the call"),
			MonitorResult.Stops[1].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepAfterCallLine")));

		if (MonitorResult.Stops[0].Callstack.IsSet())
		{
			TestEqual(TEXT("Stepping.StepOver should stay in the same frame depth"),
				MonitorResult.Stops[1].Callstack->Frames.Num(),
				MonitorResult.Stops[0].Callstack->Frames.Num());
		}
	}

	TestTrue(TEXT("Stepping.StepOver should execute successfully"), InvocationState->bSucceeded);
	return !HasAnyErrors();
}

bool FAngelscriptDebuggerSteppingStepOutTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartSteppingDebuggerSession(*this, Session, Client))
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

	if (!TestTrue(TEXT("Stepping.StepOut should compile the stepping fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FStepMonitorPhase> Phases;
	Phases.Add({ EStepMonitorAction::StepIn, true });
	Phases.Add({ EStepMonitorAction::StepOut, true });
	Phases.Add({ EStepMonitorAction::Continue, true });

	TAtomic<bool> bMonitorReady{ false };
	TFuture<FStepMonitorResult> MonitorFuture;
	if (!StartAndWaitForStepMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Stepping.StepOut should set the call-site breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForSteppingBreakpointCount(*this, Session, 1, TEXT("Stepping.StepOut should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncSteppingInvocationState> InvocationState = DispatchSteppingModuleInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForSteppingInvocationCompletion(*this, Session, InvocationState, TEXT("Stepping.StepOut should finish after monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	const FStepMonitorResult MonitorResult = MonitorFuture.Get();
	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	if (!TestEqual(TEXT("Stepping.StepOut should emit exactly 3 stops"), MonitorResult.Stops.Num(), 3))
	{
		return false;
	}

	if (TestTrue(TEXT("Stepping.StepOut second stop should have a callstack"), MonitorResult.Stops[1].Callstack.IsSet()))
	{
		TestTrue(TEXT("Stepping.StepOut should be inside the callee before stepping out"),
			MonitorResult.Stops[1].Callstack->Frames.Num() >= 2);
		TestEqual(TEXT("Stepping.StepOut should enter Inner() before stepping out"),
			MonitorResult.Stops[1].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepInnerEntryLine")));
	}

	if (TestTrue(TEXT("Stepping.StepOut third stop should have a callstack"), MonitorResult.Stops[2].Callstack.IsSet()))
	{
		TestEqual(TEXT("Stepping.StepOut should return to the line after the call"),
			MonitorResult.Stops[2].Callstack->Frames[0].LineNumber,
			Fixture.GetLine(TEXT("StepAfterCallLine")));
		if (MonitorResult.Stops[1].Callstack.IsSet())
		{
			TestTrue(TEXT("Stepping.StepOut should reduce stack depth after returning"),
				MonitorResult.Stops[2].Callstack->Frames.Num() < MonitorResult.Stops[1].Callstack->Frames.Num());
		}
	}

	TestTrue(TEXT("Stepping.StepOut should execute successfully"), InvocationState->bSucceeded);
	return !HasAnyErrors();
}

#endif

