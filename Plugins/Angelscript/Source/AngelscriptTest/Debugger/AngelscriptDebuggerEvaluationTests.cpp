#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "HAL/PlatformProcess.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerEvaluationScopeValuesTest,
	"Angelscript.TestModule.Debugger.Evaluation.ScopeValues",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerEvaluationAdapterV1LegacyPayloadTest,
	"Angelscript.TestModule.Debugger.Evaluation.AdapterV1LegacyPayload",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Debugger_AngelscriptDebuggerEvaluationTests_Private
{
	bool StartEvaluationDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client,
		int32 AdapterVersion = 2)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger evaluation should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger evaluation should connect the primary debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		bool bSentStartDebugging = false;
		const bool bStartMessageSent = Session.PumpUntil(
			[&Client, &bSentStartDebugging, AdapterVersion]()
			{
				if (bSentStartDebugging)
				{
					return true;
				}

				bSentStartDebugging = Client.SendStartDebugging(AdapterVersion);
				return bSentStartDebugging;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger evaluation should send StartDebugging"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger evaluation should receive the DebugServerVersion response"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForEvaluationBreakpointCount(
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

	struct FAsyncGeneratedInvocationState : public TSharedFromThis<FAsyncGeneratedInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bResolvedClass = false;
		bool bResolvedFunction = false;
		bool bCreatedObject = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncGeneratedInvocationState> DispatchGeneratedIntInvocation(
		FAngelscriptEngine& Engine,
		const FAngelscriptDebuggerScriptFixture& Fixture)
	{
		TSharedRef<FAsyncGeneratedInvocationState> State = MakeShared<FAsyncGeneratedInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Fixture, State]()
		{
			UClass* GeneratedClass = Fixture.FindGeneratedClass(Engine);
			State->bResolvedClass = GeneratedClass != nullptr;

			UFunction* EntryFunction = Fixture.FindGeneratedFunction(Engine, Fixture.EntryFunctionName);
			State->bResolvedFunction = EntryFunction != nullptr;

			if (GeneratedClass != nullptr && EntryFunction != nullptr)
			{
				UObject* Object = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
				State->bCreatedObject = Object != nullptr;

				if (Object != nullptr)
				{
					int32 InvocationResult = 0;
					State->bSucceeded = ExecuteGeneratedIntEventOnGameThread(&Engine, Object, EntryFunction, InvocationResult);
					State->Result = InvocationResult;
				}
			}

			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForGeneratedInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncGeneratedInvocationState>& InvocationState,
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

	template <typename T>
	bool WaitForTypedMessage(
		FAngelscriptDebuggerTestClient& Client,
		EDebugMessageType ExpectedType,
		float TimeoutSeconds,
		TOptional<T>& OutValue,
		FString& OutError,
		const TCHAR* Context)
	{
		OutValue = Client.WaitForTypedMessage<T>(ExpectedType, TimeoutSeconds);
		if (!OutValue.IsSet())
		{
			OutError = FString::Printf(TEXT("%s: %s"), Context, *Client.GetLastError());
			return false;
		}

		return true;
	}

	bool AssertLegacyVariablePayload(FAutomationTestBase& Test, const FAngelscriptVariable& Variable, const TCHAR* Context)
	{
		const FString AddressContext = FString::Printf(TEXT("%s should report ValueAddress = 0 for adapter v1"), Context);
		const FString SizeContext = FString::Printf(TEXT("%s should report ValueSize = 0 for adapter v1"), Context);
		const bool bAddressMatches = Test.TestEqual(*AddressContext, Variable.ValueAddress, static_cast<uint64>(0));
		const bool bSizeMatches = Test.TestEqual(*SizeContext, Variable.ValueSize, static_cast<uint8>(0));
		return bAddressMatches && bSizeMatches;
	}

	bool AssertLegacyVariablePayloads(
		FAutomationTestBase& Test,
		const TArray<FAngelscriptVariable>& Variables,
		const TCHAR* Context)
	{
		bool bAllMatch = true;
		for (const FAngelscriptVariable& Variable : Variables)
		{
			const FString VariableContext = FString::Printf(TEXT("%s variable '%s'"), Context, *Variable.Name);
			bAllMatch &= AssertLegacyVariablePayload(Test, Variable, *VariableContext);
		}

		return bAllMatch;
	}

	struct FEvaluationMonitorResult
	{
		TArray<FAngelscriptDebugMessageEnvelope> StopEnvelopes;
		TOptional<FStoppedMessage> StopMessage;
		TOptional<FAngelscriptCallStack> Callstack;
		TOptional<FAngelscriptVariable> LeafLocalValue;
		TOptional<FAngelscriptVariable> LeafCombinedValue;
		TOptional<FAngelscriptVariable> ThisMemberValue;
		TOptional<FAngelscriptVariable> ModuleGlobalCounterValue;
		TOptional<FAngelscriptVariables> LocalScopeVariables;
		TOptional<FAngelscriptVariables> ThisScopeVariables;
		TOptional<FAngelscriptVariables> ModuleScopeVariables;
		int32 ContinuedCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FEvaluationMonitorResult> StartEvaluationMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		const FAngelscriptDebuggerScriptFixture& Fixture,
		float TimeoutSeconds,
		int32 AdapterVersion = 2)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Fixture, TimeoutSeconds, AdapterVersion]() -> FEvaluationMonitorResult
			{
				FEvaluationMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Evaluation monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
						bSentStart = MonitorClient.SendStartDebugging(AdapterVersion);
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
					Result.Error = TEXT("Evaluation monitor timed out waiting for DebugServerVersion.");
					Result.bTimedOut = true;
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				TOptional<FAngelscriptDebugMessageEnvelope> StopEnvelope = MonitorClient.WaitForMessageType(EDebugMessageType::HasStopped, TimeoutSeconds);
				if (!StopEnvelope.IsSet())
				{
					Result.Error = FString::Printf(TEXT("Evaluation monitor timed out waiting for HasStopped: %s"), *MonitorClient.GetLastError());
					Result.bTimedOut = true;
					return Result;
				}

				Result.StopEnvelopes.Add(StopEnvelope.GetValue());
				Result.StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(StopEnvelope.GetValue());
				if (!Result.StopMessage.IsSet())
				{
					Result.Error = TEXT("Evaluation monitor failed to deserialize the HasStopped payload.");
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack() ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::CallStack, TimeoutSeconds, Result.Callstack, Result.Error, TEXT("Evaluation monitor failed to receive CallStack")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(Fixture.GetEvalPath(TEXT("LeafLocalValuePath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Evaluate, TimeoutSeconds, Result.LeafLocalValue, Result.Error, TEXT("Evaluation monitor failed to receive LocalValue evaluate reply")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(Fixture.GetEvalPath(TEXT("LeafCombinedPath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Evaluate, TimeoutSeconds, Result.LeafCombinedValue, Result.Error, TEXT("Evaluation monitor failed to receive Combined evaluate reply")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(Fixture.GetEvalPath(TEXT("ThisMemberValuePath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Evaluate, TimeoutSeconds, Result.ThisMemberValue, Result.Error, TEXT("Evaluation monitor failed to receive MemberValue evaluate reply")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(Fixture.GetEvalPath(TEXT("ModuleGlobalCounterPath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Evaluate, TimeoutSeconds, Result.ModuleGlobalCounterValue, Result.Error, TEXT("Evaluation monitor failed to receive GlobalCounter evaluate reply")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestVariables(Fixture.GetEvalPath(TEXT("LocalScopePath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Variables, TimeoutSeconds, Result.LocalScopeVariables, Result.Error, TEXT("Evaluation monitor failed to receive local scope variables")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestVariables(Fixture.GetEvalPath(TEXT("ThisScopePath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Variables, TimeoutSeconds, Result.ThisScopeVariables, Result.Error, TEXT("Evaluation monitor failed to receive this scope variables")))
				{
					return Result;
				}

				if (!MonitorClient.SendRequestVariables(Fixture.GetEvalPath(TEXT("ModuleScopePath"))) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Variables, TimeoutSeconds, Result.ModuleScopeVariables, Result.Error, TEXT("Evaluation monitor failed to receive module scope variables")))
				{
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Evaluation monitor failed to send Continue: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!MonitorClient.WaitForMessageType(EDebugMessageType::HasContinued, TimeoutSeconds).IsSet())
				{
					Result.Error = FString::Printf(TEXT("Evaluation monitor timed out waiting for HasContinued: %s"), *MonitorClient.GetLastError());
					Result.bTimedOut = true;
					return Result;
				}

				Result.ContinuedCount = 1;
				return Result;
			});
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerEvaluationTests_Private;

bool FAngelscriptDebuggerEvaluationScopeValuesTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartEvaluationDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateCallstackFixture();
	FAngelscriptEngine& Engine = Session.GetEngine();

	ON_SCOPE_EXIT
	{
		FAngelscriptClearBreakpoints ClearBreakpoints;
		ClearBreakpoints.Filename = Fixture.Filename;
		ClearBreakpoints.ModuleName = Fixture.ModuleName.ToString();
		Client.SendClearBreakpoints(ClearBreakpoints);
		Client.SendDisconnect();
		Client.Disconnect();
	};

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should compile the callstack fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TAtomic<bool> bMonitorReady(false);
	TAtomic<bool> bShouldStop(false);
	TFuture<FEvaluationMonitorResult> MonitorFuture = StartEvaluationMonitor(
		Session.GetPort(),
		bMonitorReady,
		bShouldStop,
		Fixture,
		Session.GetDefaultTimeoutSeconds());
	ON_SCOPE_EXIT
	{
		bShouldStop = true;
		if (MonitorFuture.IsValid())
		{
			MonitorFuture.Wait();
		}
	};

	const bool bMonitorStarted = Session.PumpUntil(
		[&bMonitorReady]()
		{
			return bMonitorReady.Load();
		},
		Session.GetDefaultTimeoutSeconds());
	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should bring the evaluation monitor up before execution"), bMonitorStarted))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Id = 7;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("CallstackLeafLine"));

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should send the leaf breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForEvaluationBreakpointCount(*this, Session, 1, TEXT("Debugger.Evaluation.ScopeValues should observe the breakpoint registration after both debugger clients finish handshaking")))
	{
		return false;
	}

	const TSharedRef<FAsyncGeneratedInvocationState> InvocationState = DispatchGeneratedIntInvocation(Engine, Fixture);
	if (!WaitForGeneratedInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Evaluation.ScopeValues should complete the generated invocation after the monitor resumes execution")))
	{
		return false;
	}

	bShouldStop = true;
	const FEvaluationMonitorResult MonitorResult = MonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should resolve the generated class before invocation"), InvocationState->bResolvedClass))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should resolve the generated Entry function before invocation"), InvocationState->bResolvedFunction))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should create a generated UObject instance before invocation"), InvocationState->bCreatedObject))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should finish without monitor errors"), MonitorResult.Error.IsEmpty()))
	{
		AddError(MonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Evaluation.ScopeValues should not time out while collecting debugger payloads"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Evaluation.ScopeValues should capture exactly one HasStopped event"), MonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should deserialize the stop payload"), MonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should capture a callstack"), MonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should capture all evaluate replies"), MonitorResult.LeafLocalValue.IsSet() && MonitorResult.LeafCombinedValue.IsSet() && MonitorResult.ThisMemberValue.IsSet() && MonitorResult.ModuleGlobalCounterValue.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should capture the local scope variables"), MonitorResult.LocalScopeVariables.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should capture the this scope variables"), MonitorResult.ThisScopeVariables.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should capture the module scope variables"), MonitorResult.ModuleScopeVariables.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Evaluation.ScopeValues should return at least three frames"), Callstack.Frames.Num() >= 3))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should stop because of a breakpoint"), MonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report the leaf line on the top frame"), Callstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("CallstackLeafLine")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report the middle line on the second frame"), Callstack.Frames[1].LineNumber, Fixture.GetLine(TEXT("CallstackMiddleLine")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report the entry line on the third frame"), Callstack.Frames[2].LineNumber, Fixture.GetLine(TEXT("CallstackEntryLine")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should evaluate LocalValue to 4"), MonitorResult.LeafLocalValue->Value, FString(TEXT("4")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should evaluate Combined to 16"), MonitorResult.LeafCombinedValue->Value, FString(TEXT("16")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should evaluate this.MemberValue to 5"), MonitorResult.ThisMemberValue->Value, FString(TEXT("5")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should evaluate %module%.GlobalCounter to 7"), MonitorResult.ModuleGlobalCounterValue->Value, FString(TEXT("7")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should observe a single HasContinued after resuming"), MonitorResult.ContinuedCount, 1);
	TestTrue(TEXT("Debugger.Evaluation.ScopeValues should finish the generated invocation successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should preserve the generated invocation return value"), InvocationState->Result, 16);

	const TArray<FAngelscriptVariable>& LocalVariables = MonitorResult.LocalScopeVariables->Variables;
	const TArray<FAngelscriptVariable>& ThisVariables = MonitorResult.ThisScopeVariables->Variables;
	const TArray<FAngelscriptVariable>& ModuleVariables = MonitorResult.ModuleScopeVariables->Variables;
	const FAngelscriptVariable* LocalValueVariable = LocalVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("LocalValue");
	});
	const FAngelscriptVariable* CombinedVariable = LocalVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("Combined");
	});
	const FAngelscriptVariable* MemberValueVariable = ThisVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("MemberValue");
	});
	const FAngelscriptVariable* GlobalCounterVariable = ModuleVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("GlobalCounter");
	});
	if (!TestNotNull(TEXT("Debugger.Evaluation.ScopeValues should include LocalValue in the local scope"), LocalValueVariable))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Debugger.Evaluation.ScopeValues should include Combined in the local scope"), CombinedVariable))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Debugger.Evaluation.ScopeValues should include MemberValue in the this scope"), MemberValueVariable))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Debugger.Evaluation.ScopeValues should include GlobalCounter in the module scope"), GlobalCounterVariable))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report LocalValue = 4 in the local scope"), LocalValueVariable->Value, FString(TEXT("4")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report Combined = 16 in the local scope"), CombinedVariable->Value, FString(TEXT("16")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report MemberValue = 5 in the this scope"), MemberValueVariable->Value, FString(TEXT("5")));
	TestEqual(TEXT("Debugger.Evaluation.ScopeValues should report GlobalCounter = 7 in the module scope"), GlobalCounterVariable->Value, FString(TEXT("7")));
	TestTrue(TEXT("Debugger.Evaluation.ScopeValues should expose a non-zero ValueAddress for this.MemberValue through %this% scope"), MemberValueVariable->ValueAddress != 0);
	TestTrue(TEXT("Debugger.Evaluation.ScopeValues should expose a non-zero ValueAddress for %module%.GlobalCounter through module scope"), GlobalCounterVariable->ValueAddress != 0);
	return !HasAnyErrors();
}

bool FAngelscriptDebuggerEvaluationAdapterV1LegacyPayloadTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartEvaluationDebuggerSession(*this, Session, Client, 1))
	{
		return false;
	}

	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateCallstackFixture();
	FAngelscriptEngine& Engine = Session.GetEngine();

	ON_SCOPE_EXIT
	{
		FAngelscriptClearBreakpoints ClearBreakpoints;
		ClearBreakpoints.Filename = Fixture.Filename;
		ClearBreakpoints.ModuleName = Fixture.ModuleName.ToString();
		Client.SendClearBreakpoints(ClearBreakpoints);
		Client.SendDisconnect();
		Client.Disconnect();
	};

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should compile the callstack fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Id = 20;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("CallstackLeafLine"));

	TAtomic<bool> bMonitorReady(false);
	TAtomic<bool> bShouldStop(false);
	TFuture<FEvaluationMonitorResult> MonitorFuture = StartEvaluationMonitor(
		Session.GetPort(),
		bMonitorReady,
		bShouldStop,
		Fixture,
		Session.GetDefaultTimeoutSeconds(),
		1);
	ON_SCOPE_EXIT
	{
		bShouldStop = true;
		if (MonitorFuture.IsValid())
		{
			MonitorFuture.Wait();
		}
	};

	const bool bMonitorStarted = Session.PumpUntil(
		[&bMonitorReady]()
		{
			return bMonitorReady.Load();
		},
		Session.GetDefaultTimeoutSeconds());
	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should bring the evaluation monitor up before execution"), bMonitorStarted))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should send the leaf breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForEvaluationBreakpointCount(*this, Session, 1, TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should observe the breakpoint registration after both debugger clients finish handshaking")))
	{
		return false;
	}

	const TSharedRef<FAsyncGeneratedInvocationState> InvocationState = DispatchGeneratedIntInvocation(Engine, Fixture);

	if (!WaitForGeneratedInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should complete the generated invocation after resume")))
	{
		return false;
	}

	bShouldStop = true;
	const FEvaluationMonitorResult MonitorResult = MonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should resolve the generated class before invocation"), InvocationState->bResolvedClass))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should resolve the generated Entry function before invocation"), InvocationState->bResolvedFunction))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should create a generated UObject instance before invocation"), InvocationState->bCreatedObject))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should finish without monitor errors"), MonitorResult.Error.IsEmpty()))
	{
		AddError(MonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should not time out while collecting debugger payloads"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should capture exactly one HasStopped event"), MonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should deserialize the stop payload"), MonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should deserialize the evaluate payload"), MonitorResult.LeafCombinedValue.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should deserialize the variables payload"), MonitorResult.LocalScopeVariables.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should stop because of a breakpoint"), MonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should evaluate Name = Combined"), MonitorResult.LeafCombinedValue->Name, FString(TEXT("Combined")));
	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should evaluate Value = 16"), MonitorResult.LeafCombinedValue->Value, FString(TEXT("16")));
	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should evaluate Type = int"), MonitorResult.LeafCombinedValue->Type, FString(TEXT("int")));
	if (!AssertLegacyVariablePayload(*this, MonitorResult.LeafCombinedValue.GetValue(), TEXT("Debugger.Evaluation.AdapterV1LegacyPayload evaluate reply")))
	{
		return false;
	}

	const TArray<FAngelscriptVariable>& LocalVariables = MonitorResult.LocalScopeVariables->Variables;
	const FAngelscriptVariable* LocalValueVariable = LocalVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("LocalValue");
	});
	const FAngelscriptVariable* LocalCombinedVariable = LocalVariables.FindByPredicate([](const FAngelscriptVariable& Variable)
	{
		return Variable.Name == TEXT("Combined");
	});
	if (!TestNotNull(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should include LocalValue in the local scope"), LocalValueVariable))
	{
		return false;
	}

	if (!TestNotNull(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should include Combined in the local scope"), LocalCombinedVariable))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should report LocalValue = 4 in the local scope"), LocalValueVariable->Value, FString(TEXT("4")));
	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should report Combined = 16 in the local scope"), LocalCombinedVariable->Value, FString(TEXT("16")));
	if (!AssertLegacyVariablePayloads(*this, LocalVariables, TEXT("Debugger.Evaluation.AdapterV1LegacyPayload local scope")))
	{
		return false;
	}

	if (MonitorResult.LeafLocalValue.IsSet() &&
		!AssertLegacyVariablePayload(*this, MonitorResult.LeafLocalValue.GetValue(), TEXT("Debugger.Evaluation.AdapterV1LegacyPayload local evaluate reply")))
	{
		return false;
	}

	if (MonitorResult.ThisMemberValue.IsSet() &&
		!AssertLegacyVariablePayload(*this, MonitorResult.ThisMemberValue.GetValue(), TEXT("Debugger.Evaluation.AdapterV1LegacyPayload this-member evaluate reply")))
	{
		return false;
	}

	if (MonitorResult.ModuleGlobalCounterValue.IsSet() &&
		!AssertLegacyVariablePayload(*this, MonitorResult.ModuleGlobalCounterValue.GetValue(), TEXT("Debugger.Evaluation.AdapterV1LegacyPayload module-global evaluate reply")))
	{
		return false;
	}

	if (MonitorResult.ThisScopeVariables.IsSet() &&
		!AssertLegacyVariablePayloads(*this, MonitorResult.ThisScopeVariables->Variables, TEXT("Debugger.Evaluation.AdapterV1LegacyPayload this scope")))
	{
		return false;
	}

	if (MonitorResult.ModuleScopeVariables.IsSet() &&
		!AssertLegacyVariablePayloads(*this, MonitorResult.ModuleScopeVariables->Variables, TEXT("Debugger.Evaluation.AdapterV1LegacyPayload module scope")))
	{
		return false;
	}

	TestTrue(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should finish the generated invocation successfully"), InvocationState->bSucceeded);
	TestEqual(TEXT("Debugger.Evaluation.AdapterV1LegacyPayload should preserve the generated invocation return value"), InvocationState->Result, 16);
	return !HasAnyErrors();
}

#endif

