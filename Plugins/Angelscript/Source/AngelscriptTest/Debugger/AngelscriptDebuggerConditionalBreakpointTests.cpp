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

namespace AngelscriptTest_Debugger_AngelscriptDebuggerConditionalBreakpointTests_Private
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

		if (!Test.TestTrue(TEXT("Debugger client should send StartDebugging before conditional breakpoint tests"), bStartMessageSent))
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

	asIScriptFunction* FindFunctionByDeclaration(FAngelscriptEngine& Engine, const FString& Filename, FName ModuleName, const FString& Declaration)
	{
		TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Filename, ModuleName.ToString());
		if (!ModuleDesc.IsValid() || ModuleDesc->ScriptModule == nullptr)
		{
			return nullptr;
		}

		asIScriptModule* Module = ModuleDesc->ScriptModule;
		FTCHARToUTF8 DeclarationUtf8(*Declaration);
		if (asIScriptFunction* Function = Module->GetFunctionByDecl(DeclarationUtf8.Get()))
		{
			return Function;
		}

		return nullptr;
	}

	struct FAsyncIntInvocationState : public TSharedFromThis<FAsyncIntInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
		FString Error;
	};

	TSharedRef<FAsyncIntInvocationState> DispatchIntInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration,
		int32 ArgumentValue)
	{
		TSharedRef<FAsyncIntInvocationState> State = MakeShared<FAsyncIntInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, ArgumentValue, State]()
		{
			asIScriptFunction* Function = FindFunctionByDeclaration(Engine, Filename, ModuleName, Declaration);
			if (Function == nullptr)
			{
				State->Error = FString::Printf(TEXT("Failed to find script function '%s' in module '%s'."), *Declaration, *ModuleName.ToString());
				State->bCompleted = true;
				return;
			}

			FAngelscriptEngineScope EngineScope(Engine);
			asIScriptContext* Context = Engine.CreateContext();
			if (Context == nullptr)
			{
				State->Error = TEXT("Failed to create Angelscript execution context.");
				State->bCompleted = true;
				return;
			}

			ON_SCOPE_EXIT
			{
				Context->Release();
			};

			const int PrepareResult = Context->Prepare(Function);
			if (PrepareResult != asSUCCESS)
			{
				State->Error = FString::Printf(TEXT("Prepare failed with code %d for '%s'."), PrepareResult, *Declaration);
				State->bCompleted = true;
				return;
			}

			Context->SetArgDWord(0, static_cast<asDWORD>(ArgumentValue));
			const int ExecuteResult = Context->Execute();
			if (ExecuteResult != asEXECUTION_FINISHED)
			{
				State->Error = FString::Printf(TEXT("Execute failed with code %d for '%s'."), ExecuteResult, *Declaration);
				State->bCompleted = true;
				return;
			}

			State->bSucceeded = true;
			State->Result = static_cast<int32>(Context->GetReturnDWord());
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		TSharedRef<FAsyncIntInvocationState> InvocationState,
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

	struct FConditionalBreakpointMonitorResult
	{
		TArray<FAngelscriptDebugMessageEnvelope> StopEnvelopes;
		TOptional<FAngelscriptCallStack> CapturedCallstack;
		bool bTimedOut = false;
		FString Error;
	};

	struct FConditionalBreakpointMonitorConfig
	{
		bool bRequestCallstack = false;
		bool bSendContinueOnStop = true;
		int32 MaxStopsToHandle = 1;
		float TimeoutSeconds = 45.0f;
	};

	TFuture<FConditionalBreakpointMonitorResult> StartConditionalBreakpointMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		const FConditionalBreakpointMonitorConfig& Config)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Config]() -> FConditionalBreakpointMonitorResult
			{
				FConditionalBreakpointMonitorResult Result;

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
					Result.Error = TEXT("Conditional breakpoint monitor timed out waiting for DebugServerVersion handshake.");
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

					if (Envelope->MessageType != EDebugMessageType::HasStopped)
					{
						continue;
					}

					Result.StopEnvelopes.Add(Envelope.GetValue());
					if (Config.bRequestCallstack && !Result.CapturedCallstack.IsSet() && MonitorClient.SendRequestCallStack())
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

					StopsHandled++;
					if (StopsHandled >= Config.MaxStopsToHandle)
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
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerConditionalBreakpointTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerConditionalBreakpointExpressionTest,
	"Angelscript.TestModule.Debugger.Breakpoint.ConditionExpression",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerConditionalBreakpointExpressionTest::RunTest(const FString& Parameters)
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

	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should compile the breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModuleByFilenameOrModuleName(Fixture.Filename, Fixture.ModuleName.ToString());
	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should resolve the compiled module immediately after compilation"), ModuleDesc.IsValid() && ModuleDesc->ScriptModule != nullptr))
	{
		return false;
	}

	TAtomic<bool> bPositiveMonitorReady{false};
	FConditionalBreakpointMonitorConfig PositiveMonitorConfig;
	PositiveMonitorConfig.bRequestCallstack = true;
	PositiveMonitorConfig.bSendContinueOnStop = true;
	PositiveMonitorConfig.MaxStopsToHandle = 1;
	PositiveMonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FConditionalBreakpointMonitorResult> PositiveMonitorFuture = StartConditionalBreakpointMonitor(
		Session.GetPort(),
		bPositiveMonitorReady,
		bMonitorShouldStop,
		PositiveMonitorConfig);

	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should start the positive-run monitor"), Session.PumpUntil([&bPositiveMonitorReady]() { return bPositiveMonitorReady.Load(); }, Session.GetDefaultTimeoutSeconds())))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BreakpointHelperLine"));
	Breakpoint.Condition = TEXT("Input > 0");
	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should send the conditional breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBreakpointCount(*this, Session, 1, TEXT("Debugger.Breakpoint.ConditionExpression should observe the conditional breakpoint registration before running the positive case")))
	{
		return false;
	}

	TSharedRef<FAsyncIntInvocationState> PositiveInvocation = DispatchIntInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		TEXT("int Helper(int Input)"),
		3);

	if (!WaitForInvocationCompletion(*this, Session, PositiveInvocation, TEXT("Debugger.Breakpoint.ConditionExpression should finish the positive invocation after the monitor resumes execution")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FConditionalBreakpointMonitorResult PositiveMonitorResult = PositiveMonitorFuture.Get();
	if (!TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should stop exactly once when the condition is true"), PositiveMonitorResult.StopEnvelopes.Num(), 1))
	{
		if (!PositiveMonitorResult.Error.IsEmpty())
		{
			AddError(PositiveMonitorResult.Error);
		}
		return false;
	}

	const TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(PositiveMonitorResult.StopEnvelopes[0]);
	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should deserialize the positive stop payload"), StopMessage.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should stop because of a breakpoint when the condition is true"), StopMessage->Reason, FString(TEXT("breakpoint")));
	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should capture a callstack when the condition is true"), PositiveMonitorResult.CapturedCallstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& PositiveCallstack = PositiveMonitorResult.CapturedCallstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should return at least one stack frame for the positive stop"), PositiveCallstack.Frames.Num() > 0))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should report the fixture filename in the top stack frame"), PositiveCallstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should stop at the requested helper line when the condition is true"), PositiveCallstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BreakpointHelperLine")));
	TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should execute the positive case successfully"), PositiveInvocation->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should keep the positive helper return value"), PositiveInvocation->Result, 8);

	bMonitorShouldStop = false;
	TAtomic<bool> bNegativeMonitorReady{false};
	FConditionalBreakpointMonitorConfig NegativeMonitorConfig;
	NegativeMonitorConfig.bRequestCallstack = false;
	NegativeMonitorConfig.bSendContinueOnStop = true;
	NegativeMonitorConfig.MaxStopsToHandle = 1;
	NegativeMonitorConfig.TimeoutSeconds = Session.GetDefaultTimeoutSeconds();

	TFuture<FConditionalBreakpointMonitorResult> NegativeMonitorFuture = StartConditionalBreakpointMonitor(
		Session.GetPort(),
		bNegativeMonitorReady,
		bMonitorShouldStop,
		NegativeMonitorConfig);

	if (!TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should start the negative-run monitor"), Session.PumpUntil([&bNegativeMonitorReady]() { return bNegativeMonitorReady.Load(); }, Session.GetDefaultTimeoutSeconds())))
	{
		return false;
	}

	TSharedRef<FAsyncIntInvocationState> NegativeInvocation = DispatchIntInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		TEXT("int Helper(int Input)"),
		-1);

	if (!WaitForInvocationCompletion(*this, Session, NegativeInvocation, TEXT("Debugger.Breakpoint.ConditionExpression should finish the negative invocation without stopping")))
	{
		bMonitorShouldStop = true;
		return false;
	}

	bMonitorShouldStop = true;
	FConditionalBreakpointMonitorResult NegativeMonitorResult = NegativeMonitorFuture.Get();

	TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should not stop when the condition is false"), NegativeMonitorResult.StopEnvelopes.Num(), 0);
	TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should keep the negative monitor error empty"), NegativeMonitorResult.Error.IsEmpty());
	TestFalse(TEXT("Debugger.Breakpoint.ConditionExpression should not time out while waiting for a false-condition run to complete"), NegativeMonitorResult.bTimedOut);
	TestTrue(TEXT("Debugger.Breakpoint.ConditionExpression should execute the negative case successfully"), NegativeInvocation->bSucceeded);
	TestEqual(TEXT("Debugger.Breakpoint.ConditionExpression should keep the negative helper return value"), NegativeInvocation->Result, 4);

	return !HasAnyErrors();
}

#endif

