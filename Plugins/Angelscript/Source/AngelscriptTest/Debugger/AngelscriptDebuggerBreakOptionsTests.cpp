#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptNativeScriptTestObject.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Core/AngelscriptRuntimeModule.h"

#include "Algo/AllOf.h"
#include "Async/Async.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Misc/ScopeLock.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakOptionsTests_Private
{
	class FScopedDebugBreakOptionsBinding
	{
	public:
		explicit FScopedDebugBreakOptionsBinding(TFunction<bool(const FAngelscriptDebugBreakOptions&, UObject*)> InShouldBreak)
			: TargetDelegate(FAngelscriptRuntimeModule::GetDebugCheckBreakOptions())
			, PreviousDelegate(TargetDelegate)
			, ShouldBreak(MoveTemp(InShouldBreak))
		{
			TargetDelegate.BindLambda([this](const FAngelscriptDebugBreakOptions& BreakOptions, UObject* WorldContext)
			{
				return ShouldBreak(BreakOptions, WorldContext);
			});
		}

		~FScopedDebugBreakOptionsBinding()
		{
			TargetDelegate = MoveTemp(PreviousDelegate);
		}

	private:
		FAngelscriptDebugCheckBreakOptions& TargetDelegate;
		FAngelscriptDebugCheckBreakOptions PreviousDelegate;
		TFunction<bool(const FAngelscriptDebugBreakOptions&, UObject*)> ShouldBreak;
	};

	bool StartDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger break-options test should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger break-options test should connect the primary debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger break-options test should send StartDebugging before exercising break filters"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger break-options test should receive the DebugServerVersion response"), bReceivedVersion))
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
				const TSharedPtr<FAngelscriptDebugServer::FFileBreakpoints>* ActiveBreakpoints = Session.GetDebugServer().Breakpoints.Find(ModuleKey);
				return ActiveBreakpoints != nullptr && ActiveBreakpoints->IsValid() && (*ActiveBreakpoints)->Lines.Contains(ExpectedLine);
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bFoundBreakpoint);
	}

	bool WaitForBreakOptionsState(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TArray<FName>& ExpectedFilters,
		const TArray<FName>& RejectedFilters,
		const TCHAR* Context)
	{
		const bool bObservedExpectedState = Session.PumpUntil(
			[&Session, &ExpectedFilters, &RejectedFilters]()
			{
				const TArray<FName>& ActiveBreakOptions = Session.GetDebugServer().BreakOptions;
				for (const FName& ExpectedFilter : ExpectedFilters)
				{
					if (!ActiveBreakOptions.Contains(ExpectedFilter))
					{
						return false;
					}
				}

				for (const FName& RejectedFilter : RejectedFilters)
				{
					if (ActiveBreakOptions.Contains(RejectedFilter))
					{
						return false;
					}
				}

				return true;
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bObservedExpectedState);
	}

	struct FAsyncModuleInvocationState : public TSharedFromThis<FAsyncModuleInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncModuleInvocationState> DispatchModuleInvocation(
		FAngelscriptEngine& Engine,
		UObject* WorldContext,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncModuleInvocationState> State = MakeShared<FAsyncModuleInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, WorldContext, Filename, ModuleName, Declaration, State]()
		{
			if (WorldContext == nullptr)
			{
				State->bCompleted = true;
				return;
			}

			TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Filename, ModuleName.ToString());
			if (!ModuleDesc.IsValid() || ModuleDesc->ScriptModule == nullptr)
			{
				State->bCompleted = true;
				return;
			}

			asIScriptModule* Module = ModuleDesc->ScriptModule;
			asIScriptFunction* Function = Module->GetFunctionByDecl(TCHAR_TO_ANSI(*Declaration));
			if (Function == nullptr)
			{
				State->bCompleted = true;
				return;
			}

			FAngelscriptEngineScope EngineScope(Engine, WorldContext);
			asIScriptContext* Context = Engine.CreateContext();
			if (Context == nullptr)
			{
				State->bCompleted = true;
				return;
			}

			ON_SCOPE_EXIT
			{
				Context->Release();
			};

			if (Context->Prepare(Function) != asSUCCESS)
			{
				State->bCompleted = true;
				return;
			}

			if (Context->Execute() != asEXECUTION_FINISHED)
			{
				State->bCompleted = true;
				return;
			}

			State->Result = static_cast<int32>(Context->GetReturnDWord());
			State->bSucceeded = true;
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
					Result.Error = FString::Printf(TEXT("Break-options monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
					Result.Error = TEXT("Break-options monitor timed out waiting for DebugServerVersion handshake.");
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

		if (!Test.TestTrue(TEXT("Break-options monitor should become ready within the timeout"), bReady))
		{
			bShouldStop = true;
			return false;
		}

		return true;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerBreakOptionsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBreakpointBreakOptionsGateStopTest,
	"Angelscript.TestModule.Debugger.Breakpoint.BreakOptionsGateStop",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerBreakpointBreakOptionsGateStopTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBreakpointFixture();
	UObject* BreakOptionsWorldContext = NewObject<UAngelscriptNativeScriptTestObject>();
	if (!TestNotNull(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should create a non-null world context for break-option gating"), BreakOptionsWorldContext))
	{
		return false;
	}
	ON_SCOPE_EXIT
	{
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	struct FObservedBreakOptionsState
	{
		mutable FCriticalSection Mutex;
		TArray<TArray<FName>> Calls;
		TArray<TWeakObjectPtr<UObject>> WorldContexts;

		bool Record(const FAngelscriptDebugBreakOptions& BreakOptions, UObject* WorldContext)
		{
			FScopeLock Lock(&Mutex);
			Calls.Add(BreakOptions);
			WorldContexts.Add(WorldContext);
			return BreakOptions.Contains(FName(TEXT("break:test")));
		}
	};

	FObservedBreakOptionsState ObservedBreakOptions;
	FScopedDebugBreakOptionsBinding ScopedBreakOptionsBinding(
		[&ObservedBreakOptions](const FAngelscriptDebugBreakOptions& BreakOptions, UObject* WorldContext)
		{
			return ObservedBreakOptions.Record(BreakOptions, WorldContext);
		});

	auto RunBreakpointRound =
		[this, &Session, &Client, &Engine, &Fixture, BreakOptionsWorldContext](
			int32 BreakpointId,
			const TArray<FString>& Filters,
			const TArray<FName>& ExpectedFilters,
			const TArray<FName>& RejectedFilters,
			FBreakpointMonitorResult& OutMonitorResult,
			TSharedRef<FAsyncModuleInvocationState>& OutInvocationState,
			const TCHAR* SendContext,
			const TCHAR* StateContext,
			const TCHAR* InvocationContext) -> bool
		{
			Client.DrainPendingMessages();

			TAtomic<bool> bMonitorReady{false};
			TAtomic<bool> bMonitorShouldStop{false};
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
			Breakpoint.Id = BreakpointId;
			Breakpoint.Filename = Fixture.Filename;
			Breakpoint.ModuleName = Fixture.ModuleName.ToString();
			Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointHelperLine"));
			if (!TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should register the round-specific breakpoint after the monitor starts debugging"), Client.SendSetBreakpoint(Breakpoint)))
			{
				bMonitorShouldStop = true;
				AddError(Client.GetLastError());
				return false;
			}

			if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger.Breakpoint.BreakOptionsGateStop should observe exactly one registered breakpoint after the round-specific registration")))
			{
				bMonitorShouldStop = true;
				return false;
			}

			if (!WaitForSpecificBreakpoint(
				*this,
				Session,
				Fixture.ModuleName.ToString(),
				Fixture.GetLine(TEXT("BreakpointHelperLine")),
				TEXT("Debugger.Breakpoint.BreakOptionsGateStop should resolve the requested helper-line breakpoint before running the script")))
			{
				bMonitorShouldStop = true;
				return false;
			}

			if (!this->TestTrue(SendContext, Client.SendBreakOptions(Filters)))
			{
				bMonitorShouldStop = true;
				AddError(Client.GetLastError());
				return false;
			}

			if (!WaitForBreakOptionsState(*this, Session, ExpectedFilters, RejectedFilters, StateContext))
			{
				bMonitorShouldStop = true;
				return false;
			}

			OutInvocationState = DispatchModuleInvocation(
				Engine,
				BreakOptionsWorldContext,
				Fixture.Filename,
				Fixture.ModuleName,
				Fixture.EntryFunctionDeclaration);

			if (!WaitForInvocationCompletion(*this, Session, OutInvocationState, InvocationContext))
			{
				bMonitorShouldStop = true;
				return false;
			}

			bMonitorShouldStop = true;
			OutMonitorResult = MonitorFuture.Get();
			return true;
		};

	FBreakpointMonitorResult FirstRoundMonitorResult;
	TSharedRef<FAsyncModuleInvocationState> FirstInvocationState = MakeShared<FAsyncModuleInvocationState>();
	if (!RunBreakpointRound(
		151,
		{TEXT("break:other")},
		{FName(TEXT("break:other")), FName(TEXT("break:any"))},
		{FName(TEXT("break:test"))},
		FirstRoundMonitorResult,
		FirstInvocationState,
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should send the first break-options filter set"),
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should update the server break-options state for the rejected round"),
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should complete the first invocation without stopping")))
	{
		return false;
	}

	FBreakpointMonitorResult SecondRoundMonitorResult;
	TSharedRef<FAsyncModuleInvocationState> SecondInvocationState = MakeShared<FAsyncModuleInvocationState>();
	if (!RunBreakpointRound(
		152,
		{TEXT("break:test")},
		{FName(TEXT("break:test")), FName(TEXT("break:any"))},
		{FName(TEXT("break:other"))},
		SecondRoundMonitorResult,
		SecondInvocationState,
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should send the second break-options filter set"),
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should update the server break-options state for the accepted round"),
		TEXT("Debugger.Breakpoint.BreakOptionsGateStop should complete the second invocation after the monitor resumes from the breakpoint")))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should keep the rejected-round monitor error empty"), FirstRoundMonitorResult.Error.IsEmpty());
	TestFalse(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should not time out while waiting for a rejected breakpoint stop"), FirstRoundMonitorResult.bTimedOut);
	TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should not emit any HasStopped message in the rejected round"), FirstRoundMonitorResult.StopEnvelopes.Num(), 0);
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should still execute the rejected-round invocation successfully"), FirstInvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should preserve the rejected-round script return value"), FirstInvocationState->Result, 8);

	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should keep the accepted-round monitor error empty"), SecondRoundMonitorResult.Error.IsEmpty());
	if (!TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should emit exactly one HasStopped message in the accepted round"), SecondRoundMonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	const TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(SecondRoundMonitorResult.StopEnvelopes[0]);
	if (!TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should deserialize the accepted-round stop payload"), StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should stop because of a breakpoint in the accepted round"), StopMessage->Reason, FString(TEXT("breakpoint")));
	if (!TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should capture a callstack for the accepted round"), SecondRoundMonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = SecondRoundMonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should return at least one frame in the accepted-round callstack"), Callstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should report the fixture filename in the accepted-round top stack frame"), Callstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should stop at the breakpoint helper line"), Callstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BreakpointHelperLine")));
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should execute the accepted-round invocation successfully"), SecondInvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should preserve the accepted-round script return value"), SecondInvocationState->Result, 8);

	FScopeLock Lock(&ObservedBreakOptions.Mutex);
	if (!TestEqual(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should invoke the break-options delegate exactly once per round"), ObservedBreakOptions.Calls.Num(), 2))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should pass break:other to the first delegate invocation"), ObservedBreakOptions.Calls[0].Contains(FName(TEXT("break:other"))));
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should append break:any to the first delegate invocation"), ObservedBreakOptions.Calls[0].Contains(FName(TEXT("break:any"))));
	TestFalse(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should not leak break:test into the first delegate invocation"), ObservedBreakOptions.Calls[0].Contains(FName(TEXT("break:test"))));
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should pass break:test to the second delegate invocation"), ObservedBreakOptions.Calls[1].Contains(FName(TEXT("break:test"))));
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should append break:any to the second delegate invocation"), ObservedBreakOptions.Calls[1].Contains(FName(TEXT("break:any"))));
	TestFalse(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should not leak break:other into the second delegate invocation"), ObservedBreakOptions.Calls[1].Contains(FName(TEXT("break:other"))));
	TestTrue(TEXT("Debugger.Breakpoint.BreakOptionsGateStop should provide a valid world context to every delegate invocation"), Algo::AllOf(ObservedBreakOptions.WorldContexts, [](const TWeakObjectPtr<UObject>& WorldContext) { return WorldContext.IsValid(); }));
	return !HasAnyErrors();
}

#endif

