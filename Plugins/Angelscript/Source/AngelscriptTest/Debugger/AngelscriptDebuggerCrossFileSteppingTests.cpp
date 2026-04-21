#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Core/AngelscriptEngine.h"
#include "Async/Async.h"
#include "Containers/Array.h"
#include "HAL/PlatformProcess.h"
#include "Misc/AutomationTest.h"
#include "Misc/Crc.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerCrossFileSteppingTests_Private
{
	bool StartCrossFileDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Cross-file stepping should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Cross-file stepping should connect the test client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Cross-file stepping should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Cross-file stepping should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForCrossFileBreakpointCount(
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

	struct FAsyncCrossFileInvocationState : public TSharedFromThis<FAsyncCrossFileInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncCrossFileInvocationState> DispatchCrossFileInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncCrossFileInvocationState> State = MakeShared<FAsyncCrossFileInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForCrossFileInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncCrossFileInvocationState>& InvocationState,
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

	enum class ECrossFileStepAction : uint8
	{
		Continue,
		StepIn,
		StepOver,
		StepOut,
	};

	struct FCrossFileStepPhase
	{
		ECrossFileStepAction Action = ECrossFileStepAction::Continue;
	};

	struct FCrossFileStepStop
	{
		FAngelscriptDebugMessageEnvelope StopEnvelope;
		TOptional<FAngelscriptCallStack> Callstack;
	};

	struct FCrossFileStepMonitorResult
	{
		TArray<FCrossFileStepStop> Stops;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FCrossFileStepMonitorResult> StartCrossFileStepMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FCrossFileStepPhase> Phases,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Phases = MoveTemp(Phases), TimeoutSeconds]() -> FCrossFileStepMonitorResult
			{
				FCrossFileStepMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Cross-file step monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
					Result.Error = TEXT("Cross-file step monitor timed out waiting for DebugServerVersion.");
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
						Result.Error = FString::Printf(TEXT("Cross-file step monitor received unexpected stop #%d beyond configured phases."), StopsHandled + 1);
						break;
					}

					FCrossFileStepStop Stop;
					Stop.StopEnvelope = Envelope.GetValue();

					if (MonitorClient.SendRequestCallStack())
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

					switch (Phases[StopsHandled].Action)
					{
					case ECrossFileStepAction::Continue:
						MonitorClient.SendContinue();
						break;
					case ECrossFileStepAction::StepIn:
						MonitorClient.SendStepIn();
						break;
					case ECrossFileStepAction::StepOver:
						MonitorClient.SendStepOver();
						break;
					case ECrossFileStepAction::StepOut:
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

	bool StartAndWaitForCrossFileMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TArray<FCrossFileStepPhase> Phases,
		TFuture<FCrossFileStepMonitorResult>& OutFuture)
	{
		OutFuture = StartCrossFileStepMonitor(Port, bMonitorReady, bShouldStop, MoveTemp(Phases), Session.GetDefaultTimeoutSeconds());

		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Cross-file stepping should bring the step monitor up before execution"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}

	struct FCrossFileScriptSection
	{
		FString Filename;
		FString AbsoluteFilename;
		FString ScriptSource;
	};

	struct FCrossFileSteppingFixture
	{
		FName ModuleName;
		FString EntryFunctionDeclaration;
		FString EntryFilename;
		FString CalleeFilename;
		TArray<FCrossFileScriptSection> Sections;
		TMap<FName, int32> LineMarkers;

		bool Compile(FAngelscriptEngine& Engine) const
		{
			TSharedRef<FAngelscriptModuleDesc> ModuleDesc = MakeShared<FAngelscriptModuleDesc>();
			ModuleDesc->ModuleName = ModuleName.ToString();

			for (const FCrossFileScriptSection& SectionData : Sections)
			{
				FAngelscriptModuleDesc::FCodeSection& Section = ModuleDesc->Code.AddDefaulted_GetRef();
				Section.RelativeFilename = FPaths::Combine(TEXT("Automation"), SectionData.Filename);
				Section.AbsoluteFilename = SectionData.AbsoluteFilename;
				Section.Code = SectionData.ScriptSource;
				Section.CodeHash = static_cast<int64>(FCrc::StrCrc32(*Section.Code));
				ModuleDesc->CodeHash ^= Section.CodeHash;
			}

			TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesToCompile;
			ModulesToCompile.Add(ModuleDesc);

			TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
			TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
			FScopedAutomaticImportsOverride AutomaticImportsOverride(Engine.GetScriptEngine());
			FAngelscriptEngineScope EngineScope(Engine);
			const ECompileResult CompileResult = Engine.CompileModules(ECompileType::SoftReloadOnly, ModulesToCompile, CompiledModules);
			return CompileResult == ECompileResult::FullyHandled || CompileResult == ECompileResult::PartiallyHandled;
		}

		int32 GetLine(FName Marker) const
		{
			const int32* Line = LineMarkers.Find(Marker);
			check(Line != nullptr);
			return *Line;
		}
	};

	FCrossFileScriptSection MakeCrossFileSection(const FString& Filename, const FString& RawScriptSource, TMap<FName, int32>& InOutLineMarkers)
	{
		TArray<FString> Lines;
		RawScriptSource.ParseIntoArrayLines(Lines, false);
		for (int32 LineIndex = 0; LineIndex < Lines.Num(); ++LineIndex)
		{
			FString& Line = Lines[LineIndex];
			int32 MarkerStart = INDEX_NONE;
			while (Line.FindChar(TEXT('/'), MarkerStart))
			{
				if (!Line.Mid(MarkerStart).StartsWith(TEXT("/*MARK:")))
				{
					MarkerStart += 1;
					continue;
				}

				const int32 MarkerNameStart = MarkerStart + 7;
				const int32 MarkerEnd = Line.Find(TEXT("*/"), ESearchCase::CaseSensitive, ESearchDir::FromStart, MarkerNameStart);
				if (MarkerEnd == INDEX_NONE)
				{
					break;
				}

				const FString MarkerName = Line.Mid(MarkerNameStart, MarkerEnd - MarkerNameStart);
				InOutLineMarkers.Add(FName(*MarkerName), LineIndex + 1);
				Line.RemoveAt(MarkerStart, (MarkerEnd - MarkerStart) + 2, EAllowShrinking::No);
			}
		}

		FCrossFileScriptSection Section;
		Section.Filename = Filename;
		Section.AbsoluteFilename = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Filename);
		Section.ScriptSource = FString::Join(Lines, TEXT("\n"));
		return Section;
	}

	FCrossFileSteppingFixture CreateCrossFileSteppingFixture()
	{
		FCrossFileSteppingFixture Fixture;
		Fixture.ModuleName = TEXT("DebuggerCrossFileSteppingFixture");
		Fixture.EntryFunctionDeclaration = TEXT("int RunScenario()");
		Fixture.EntryFilename = TEXT("DebuggerCrossFileSteppingA.as");
		Fixture.CalleeFilename = TEXT("DebuggerCrossFileSteppingB.as");
		Fixture.Sections.Add(MakeCrossFileSection(
			Fixture.CalleeFilename,
			TEXT(R"AS(int Inner(int Value)
{
	/*MARK:StepInnerEntryLine*/ int StoredValue = 9;
	int InnerValue = Value + StoredValue;
	return InnerValue;
}
)AS"),
			Fixture.LineMarkers));
		Fixture.Sections.Add(MakeCrossFileSection(
			Fixture.EntryFilename,
			TEXT(R"AS(int RunScenario()
{
	int StartValue = 4;
	int Seed = StartValue + 1;
	int Offset = Seed * 2;
	int Warmup = Offset - 1;
	int Guard = Warmup + 3;
	/*MARK:StepCallLine*/ int Result = Inner(Guard);
	/*MARK:StepAfterCallLine*/ Result += 1;
	return Result;
}
)AS"),
			Fixture.LineMarkers));
		return Fixture;
	}

	bool AssertTopFrameMatches(
		FAutomationTestBase& Test,
		const TOptional<FAngelscriptCallStack>& Callstack,
		const FString& ExpectedSource,
		int32 ExpectedLine,
		const TCHAR* Context)
	{
		const FString CallstackContext = FString::Printf(TEXT("%s should include a callstack"), Context);
		if (!Test.TestTrue(*CallstackContext, Callstack.IsSet()))
		{
			return false;
		}

		const FString FrameContext = FString::Printf(TEXT("%s should include at least one frame"), Context);
		if (!Test.TestTrue(*FrameContext, Callstack->Frames.Num() > 0))
		{
			return false;
		}

		const FAngelscriptCallFrame& TopFrame = Callstack->Frames[0];
		bool bPassed = true;
		const FString SourceContext = FString::Printf(TEXT("%s should report the expected source file"), Context);
		bPassed &= Test.TestTrue(
			*SourceContext,
			FPaths::IsSamePath(TopFrame.Source, ExpectedSource));
		const FString LineContext = FString::Printf(TEXT("%s should report the expected line"), Context);
		bPassed &= Test.TestEqual(
			*LineContext,
			TopFrame.LineNumber,
			ExpectedLine);
		return bPassed;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerCrossFileSteppingTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerCrossFileSteppingTest,
	"Angelscript.TestModule.Debugger.Stepping.CrossFileTransition",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerCrossFileSteppingTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartCrossFileDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FCrossFileSteppingFixture Fixture = CreateCrossFileSteppingFixture();
	TAtomic<bool> bMonitorShouldStop{ false };
	TFuture<FCrossFileStepMonitorResult> MonitorFuture;
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

	if (!TestTrue(TEXT("Cross-file stepping should compile the multi-file fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FCrossFileStepPhase> Phases;
	Phases.Add({ ECrossFileStepAction::StepIn });
	Phases.Add({ ECrossFileStepAction::StepOut });
	Phases.Add({ ECrossFileStepAction::Continue });

	TAtomic<bool> bMonitorReady{ false };
	if (!StartAndWaitForCrossFileMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}
	bMonitorStarted = true;

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.EntryFilename);
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Cross-file stepping should set the caller-side breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForCrossFileBreakpointCount(*this, Session, 1, TEXT("Cross-file stepping should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncCrossFileInvocationState> InvocationState = DispatchCrossFileInvocation(
		Engine,
		Breakpoint.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForCrossFileInvocationCompletion(*this, Session, InvocationState, TEXT("Cross-file stepping should finish after the monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	FCrossFileStepMonitorResult MonitorResult = MonitorFuture.Get();
	bMonitorResultConsumed = true;

	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	TestFalse(TEXT("Cross-file stepping should not time out"), MonitorResult.bTimedOut);
	if (!TestEqual(TEXT("Cross-file stepping should emit exactly 3 stops"), MonitorResult.Stops.Num(), 3))
	{
		return false;
	}

	const TOptional<FStoppedMessage> FirstStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[0].StopEnvelope);
	const TOptional<FStoppedMessage> SecondStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[1].StopEnvelope);
	const TOptional<FStoppedMessage> ThirdStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[2].StopEnvelope);
	TestTrue(TEXT("Cross-file stepping should deserialize the breakpoint stop"), FirstStop.IsSet());
	TestTrue(TEXT("Cross-file stepping should deserialize the step-in stop"), SecondStop.IsSet());
	TestTrue(TEXT("Cross-file stepping should deserialize the step-out stop"), ThirdStop.IsSet());
	if (FirstStop.IsSet())
	{
		TestEqual(TEXT("Cross-file stepping should first stop because of the breakpoint"), FirstStop->Reason, FString(TEXT("breakpoint")));
	}
	if (SecondStop.IsSet())
	{
		TestEqual(TEXT("Cross-file stepping should report StepIn as a step stop"), SecondStop->Reason, FString(TEXT("step")));
	}
	if (ThirdStop.IsSet())
	{
		TestEqual(TEXT("Cross-file stepping should report StepOut as a step stop"), ThirdStop->Reason, FString(TEXT("step")));
	}

	const FString EntryAbsolutePath = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.EntryFilename);
	const FString CalleeAbsolutePath = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.CalleeFilename);
	(void)AssertTopFrameMatches(*this, MonitorResult.Stops[0].Callstack, EntryAbsolutePath, Fixture.GetLine(TEXT("StepCallLine")), TEXT("Cross-file stepping first stop"));
	if (AssertTopFrameMatches(*this, MonitorResult.Stops[1].Callstack, CalleeAbsolutePath, Fixture.GetLine(TEXT("StepInnerEntryLine")), TEXT("Cross-file stepping second stop")))
	{
		TestTrue(TEXT("Cross-file stepping should enter a deeper stack frame after StepIn"), MonitorResult.Stops[1].Callstack->Frames.Num() >= 2);
	}
	if (AssertTopFrameMatches(*this, MonitorResult.Stops[2].Callstack, EntryAbsolutePath, Fixture.GetLine(TEXT("StepAfterCallLine")), TEXT("Cross-file stepping third stop"))
		&& MonitorResult.Stops[1].Callstack.IsSet())
	{
		TestTrue(TEXT("Cross-file stepping should reduce stack depth after StepOut"),
			MonitorResult.Stops[2].Callstack->Frames.Num() < MonitorResult.Stops[1].Callstack->Frames.Num());
	}

	TestTrue(TEXT("Cross-file stepping should execute successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Cross-file stepping should return the expected final result"), InvocationState->Result, 22);
	return !HasAnyErrors();
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerCrossFileStepOverStaysInCallerTest,
	"Angelscript.TestModule.Debugger.Stepping.CrossFileStepOverStaysInCaller",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerCrossFileStepOverStaysInCallerTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartCrossFileDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FCrossFileSteppingFixture Fixture = CreateCrossFileSteppingFixture();
	TAtomic<bool> bMonitorShouldStop{ false };
	TFuture<FCrossFileStepMonitorResult> MonitorFuture;
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

	if (!TestTrue(TEXT("Cross-file StepOver should compile the multi-file fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TArray<FCrossFileStepPhase> Phases;
	Phases.Add({ ECrossFileStepAction::StepOver });
	Phases.Add({ ECrossFileStepAction::Continue });

	TAtomic<bool> bMonitorReady{ false };
	if (!StartAndWaitForCrossFileMonitorReady(*this, Session, Session.GetPort(), bMonitorReady, bMonitorShouldStop, MoveTemp(Phases), MonitorFuture))
	{
		return false;
	}
	bMonitorStarted = true;

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.EntryFilename);
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepCallLine"));
	if (!TestTrue(TEXT("Cross-file StepOver should set the caller-side breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForCrossFileBreakpointCount(*this, Session, 1, TEXT("Cross-file StepOver should observe the breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncCrossFileInvocationState> InvocationState = DispatchCrossFileInvocation(
		Engine,
		Breakpoint.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);

	if (!WaitForCrossFileInvocationCompletion(*this, Session, InvocationState, TEXT("Cross-file StepOver should finish after the monitor continues execution")))
	{
		return false;
	}

	bMonitorShouldStop = true;
	FCrossFileStepMonitorResult MonitorResult = MonitorFuture.Get();
	bMonitorResultConsumed = true;

	if (!MonitorResult.Error.IsEmpty())
	{
		AddError(MonitorResult.Error);
	}

	TestFalse(TEXT("Cross-file StepOver should not time out"), MonitorResult.bTimedOut);
	if (!TestEqual(TEXT("Cross-file StepOver should emit exactly 2 stops"), MonitorResult.Stops.Num(), 2))
	{
		return false;
	}

	const TOptional<FStoppedMessage> FirstStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[0].StopEnvelope);
	const TOptional<FStoppedMessage> SecondStop = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(MonitorResult.Stops[1].StopEnvelope);
	TestTrue(TEXT("Cross-file StepOver should deserialize the breakpoint stop"), FirstStop.IsSet());
	TestTrue(TEXT("Cross-file StepOver should deserialize the step stop"), SecondStop.IsSet());
	if (FirstStop.IsSet())
	{
		TestEqual(TEXT("Cross-file StepOver should first stop because of the breakpoint"), FirstStop->Reason, FString(TEXT("breakpoint")));
	}
	if (SecondStop.IsSet())
	{
		TestEqual(TEXT("Cross-file StepOver should report the second stop as a step"), SecondStop->Reason, FString(TEXT("step")));
	}

	const FString EntryAbsolutePath = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.EntryFilename);
	const FString CalleeAbsolutePath = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), Fixture.CalleeFilename);
	const bool bFirstFrameMatched = AssertTopFrameMatches(
		*this,
		MonitorResult.Stops[0].Callstack,
		EntryAbsolutePath,
		Fixture.GetLine(TEXT("StepCallLine")),
		TEXT("Cross-file StepOver first stop"));
	const bool bSecondFrameMatched = AssertTopFrameMatches(
		*this,
		MonitorResult.Stops[1].Callstack,
		EntryAbsolutePath,
		Fixture.GetLine(TEXT("StepAfterCallLine")),
		TEXT("Cross-file StepOver second stop"));
	if (bSecondFrameMatched)
	{
		const FAngelscriptCallFrame& TopFrame = MonitorResult.Stops[1].Callstack->Frames[0];
		TestFalse(TEXT("Cross-file StepOver second stop should not switch the top frame source to the callee file"), FPaths::IsSamePath(TopFrame.Source, CalleeAbsolutePath));
	}
	if (bFirstFrameMatched && bSecondFrameMatched)
	{
		TestEqual(
			TEXT("Cross-file StepOver should keep the same stack depth before and after stepping over the call"),
			MonitorResult.Stops[1].Callstack->Frames.Num(),
			MonitorResult.Stops[0].Callstack->Frames.Num());
	}

	TestTrue(TEXT("Cross-file StepOver should execute successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Cross-file StepOver should return the expected final result"), InvocationState->Result, 22);
	return !HasAnyErrors();
}

#endif

