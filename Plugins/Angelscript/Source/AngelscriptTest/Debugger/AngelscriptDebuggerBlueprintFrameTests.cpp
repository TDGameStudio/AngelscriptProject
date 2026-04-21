#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "EdGraph/EdGraph.h"
#include "EdGraphSchema_K2.h"
#include "Engine/Blueprint.h"
#include "K2Node_CallFunction.h"
#include "K2Node_FunctionEntry.h"
#include "Kismet2/BlueprintEditorUtils.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBlueprintMixedCallstackAndThisScopeTest,
	"Angelscript.TestModule.Debugger.Blueprint.MixedCallstackAndThisScope",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Debugger_AngelscriptDebuggerBlueprintFrameTests_Private
{
	static const FName BlueprintInvocationFunctionName(TEXT("CallIntoScript"));
	static const FName ScriptBreakpointFunctionName(TEXT("BreakInScript"));
	static const FName ScriptValuePropertyName(TEXT("ScriptValue"));
	static const FName LastBreakResultPropertyName(TEXT("LastBreakResult"));

	bool StartBlueprintDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client,
		int32 AdapterVersion = 2)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should connect the primary debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should send StartDebugging"), bStartMessageSent))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		TOptional<FAngelscriptDebugMessageEnvelope> VersionEnvelope;
		const bool bReceivedVersion = Session.PumpUntil(
			[&Client, &VersionEnvelope]()
			{
				const TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					VersionEnvelope = Envelope;
					return true;
				}

				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should receive the DebugServerVersion response"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForBlueprintBreakpointCount(
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

	bool WaitForVoidInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncGeneratedVoidInvocationState>& InvocationState,
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

	void CleanupBlueprint(UBlueprint*& Blueprint)
	{
		if (Blueprint == nullptr)
		{
			return;
		}

		if (UClass* BlueprintClass = Blueprint->GeneratedClass)
		{
			BlueprintClass->MarkAsGarbage();
		}

		if (UPackage* BlueprintPackage = Blueprint->GetOutermost())
		{
			BlueprintPackage->MarkAsGarbage();
		}

		Blueprint->MarkAsGarbage();
		CollectGarbage(RF_NoFlags, true);
		Blueprint = nullptr;
	}

	UBlueprint* CreateTransientBlueprintChild(
		FAutomationTestBase& Test,
		UClass* ParentClass,
		FStringView Suffix,
		const TCHAR* CallingContext = TEXT("AngelscriptDebuggerBlueprintFrameTests"))
	{
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should resolve the script parent class before creating a transient child blueprint"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptDebuggerBlueprintFrame_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should create a transient blueprint package"), BlueprintPackage))
		{
			return nullptr;
		}

		BlueprintPackage->SetFlags(RF_Transient);
		const FName BlueprintName(*FPackageName::GetLongPackageAssetName(PackagePath));
		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			BlueprintPackage,
			BlueprintName,
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			CallingContext);
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should create a transient child blueprint"), Blueprint))
		{
			return nullptr;
		}

		return Blueprint;
	}

	UK2Node_CallFunction* AddCallFunctionNode(
		UEdGraph& FunctionGraph,
		UFunction& ScriptFunction,
		UEdGraphPin* ConnectPin)
	{
		UK2Node_CallFunction* CallFunctionNode = NewObject<UK2Node_CallFunction>(&FunctionGraph);
		if (CallFunctionNode == nullptr)
		{
			return nullptr;
		}

		FunctionGraph.AddNode(CallFunctionNode, false, false);
		CallFunctionNode->CreateNewGuid();
		CallFunctionNode->PostPlacedNewNode();
		CallFunctionNode->SetFromFunction(&ScriptFunction);
		CallFunctionNode->AllocateDefaultPins();
		CallFunctionNode->NodePosX = 320;
		CallFunctionNode->NodePosY = 0;

		const UEdGraphSchema_K2* Schema = GetDefault<UEdGraphSchema_K2>();
		if (Schema != nullptr && ConnectPin != nullptr && CallFunctionNode->GetExecPin() != nullptr)
		{
			Schema->TryCreateConnection(ConnectPin, CallFunctionNode->GetExecPin());
		}

		return CallFunctionNode;
	}

	bool CreateTransientBlueprintCallingScriptFunction(
		FAutomationTestBase& Test,
		UClass& ParentClass,
		UBlueprint& Blueprint,
		FName FunctionName,
		FName ScriptFunctionName)
	{
		UFunction* ScriptFunction = ParentClass.FindFunctionByName(ScriptFunctionName);
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose the script function that the transient blueprint calls"), ScriptFunction))
		{
			return false;
		}

		UEdGraph* FunctionGraph = FBlueprintEditorUtils::CreateNewGraph(&Blueprint, FunctionName, UEdGraph::StaticClass(), UEdGraphSchema_K2::StaticClass());
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should create a Blueprint function graph"), FunctionGraph))
		{
			return false;
		}

		FBlueprintEditorUtils::AddFunctionGraph<UClass>(&Blueprint, FunctionGraph, true, nullptr);

		TArray<UK2Node_FunctionEntry*> EntryNodes;
		FunctionGraph->GetNodesOfClass(EntryNodes);
		UK2Node_FunctionEntry* EntryNode = EntryNodes.Num() > 0 ? EntryNodes[0] : nullptr;
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should create a function entry node for the Blueprint caller graph"), EntryNode))
		{
			return false;
		}

		UEdGraphPin* EntryThenPin = EntryNode->FindPin(UEdGraphSchema_K2::PN_Then);
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose the function entry exec pin"), EntryThenPin))
		{
			return false;
		}

		UK2Node_CallFunction* CallNode = AddCallFunctionNode(*FunctionGraph, *ScriptFunction, EntryThenPin);
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should place a call-function node in the transient Blueprint graph"), CallNode))
		{
			return false;
		}

		UEdGraphPin* InputPin = CallNode->FindPin(TEXT("Input"));
		if (!Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose the Input pin on the Blueprint call node"), InputPin))
		{
			return false;
		}

		InputPin->DefaultValue = TEXT("7");
		FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(&Blueprint);
		FKismetEditorUtilities::CompileBlueprint(&Blueprint);
		return Test.TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should compile the transient Blueprint caller into a generated class"), Blueprint.GeneratedClass.Get());
	}

	int32 FindCallstackFrameIndexByPrefix(const FAngelscriptCallStack& Callstack, const FString& Prefix)
	{
		for (int32 FrameIndex = 0; FrameIndex < Callstack.Frames.Num(); ++FrameIndex)
		{
			if (Callstack.Frames[FrameIndex].Name.StartsWith(Prefix))
			{
				return FrameIndex;
			}
		}

		return INDEX_NONE;
	}

	bool ReadIntProperty(
		FAutomationTestBase& Test,
		const UObject& Object,
		FName PropertyName,
		int32& OutValue,
		const TCHAR* Context)
	{
		const FIntProperty* Property = FindFProperty<FIntProperty>(Object.GetClass(), PropertyName);
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should expose int property '%s'"), Context, *PropertyName.ToString()), Property))
		{
			return false;
		}

		OutValue = Property->GetPropertyValue_InContainer(&Object);
		return true;
	}

	struct FBlueprintFrameMonitorResult
	{
		TOptional<FStoppedMessage> StopMessage;
		TOptional<FAngelscriptCallStack> Callstack;
		TOptional<FAngelscriptVariable> BlueprintScriptValue;
		TOptional<FAngelscriptVariables> BlueprintThisScope;
		int32 BlueprintFrameIndex = INDEX_NONE;
		int32 ContinuedCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FBlueprintFrameMonitorResult> StartBlueprintFrameMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, TimeoutSeconds]() -> FBlueprintFrameMonitorResult
			{
				FBlueprintFrameMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Blueprint-frame monitor failed to connect: %s"), *MonitorClient.GetLastError());
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
						const TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
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
					Result.Error = TEXT("Blueprint-frame monitor timed out waiting for DebugServerVersion.");
					Result.bTimedOut = true;
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				Result.StopMessage = MonitorClient.WaitForTypedMessage<FStoppedMessage>(EDebugMessageType::HasStopped, TimeoutSeconds);
				if (!Result.StopMessage.IsSet())
				{
					Result.Error = FString::Printf(TEXT("Blueprint-frame monitor timed out waiting for HasStopped: %s"), *MonitorClient.GetLastError());
					Result.bTimedOut = true;
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack() ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::CallStack, TimeoutSeconds, Result.Callstack, Result.Error, TEXT("Blueprint-frame monitor failed to receive CallStack")))
				{
					return Result;
				}

				Result.BlueprintFrameIndex = FindCallstackFrameIndexByPrefix(Result.Callstack.GetValue(), TEXT("(BP)"));
				if (Result.BlueprintFrameIndex == INDEX_NONE)
				{
					Result.Error = TEXT("Blueprint-frame monitor failed to locate a Blueprint frame inside the returned callstack.");
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(TEXT("ScriptValue"), Result.BlueprintFrameIndex) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Evaluate, TimeoutSeconds, Result.BlueprintScriptValue, Result.Error, TEXT("Blueprint-frame monitor failed to receive Blueprint-frame ScriptValue evaluate reply")))
				{
					return Result;
				}

				const FString ThisScopePath = FString::Printf(TEXT("%d:%s"), Result.BlueprintFrameIndex, TEXT("%this%"));
				if (!MonitorClient.SendRequestVariables(ThisScopePath) ||
					!WaitForTypedMessage(MonitorClient, EDebugMessageType::Variables, TimeoutSeconds, Result.BlueprintThisScope, Result.Error, TEXT("Blueprint-frame monitor failed to receive Blueprint-frame %this% scope variables")))
				{
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Blueprint-frame monitor failed to send Continue: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!MonitorClient.WaitForMessageType(EDebugMessageType::HasContinued, TimeoutSeconds).IsSet())
				{
					Result.Error = FString::Printf(TEXT("Blueprint-frame monitor timed out waiting for HasContinued: %s"), *MonitorClient.GetLastError());
					Result.bTimedOut = true;
					return Result;
				}

				Result.ContinuedCount = 1;
				return Result;
			});
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerBlueprintFrameTests_Private;

bool FAngelscriptDebuggerBlueprintMixedCallstackAndThisScopeTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartBlueprintDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBlueprintFrameFixture();
	FAngelscriptEngine& Engine = Session.GetEngine();
	UBlueprint* Blueprint = nullptr;
	UObject* BlueprintObject = nullptr;

	ON_SCOPE_EXIT
	{
		FAngelscriptClearBreakpoints ClearBreakpoints;
		ClearBreakpoints.Filename = Fixture.Filename;
		ClearBreakpoints.ModuleName = Fixture.ModuleName.ToString();
		Client.SendClearBreakpoints(ClearBreakpoints);
		Client.SendDisconnect();
		Client.Disconnect();

		if (BlueprintObject != nullptr)
		{
			BlueprintObject->MarkAsGarbage();
			BlueprintObject = nullptr;
		}

		CleanupBlueprint(Blueprint);
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should compile the Blueprint-frame script fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	UClass* ScriptParentClass = Fixture.FindGeneratedClass(Engine);
	if (!TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should publish the script parent class"), ScriptParentClass))
	{
		return false;
	}

	Blueprint = CreateTransientBlueprintChild(*this, ScriptParentClass, TEXT("MixedCallstack"));
	if (Blueprint == nullptr)
	{
		return false;
	}

	if (!CreateTransientBlueprintCallingScriptFunction(*this, *ScriptParentClass, *Blueprint, BlueprintInvocationFunctionName, ScriptBreakpointFunctionName))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint->GeneratedClass.Get();
	if (!TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose the transient Blueprint generated class"), BlueprintClass))
	{
		return false;
	}

	BlueprintObject = NewObject<UObject>(GetTransientPackage(), BlueprintClass);
	if (!TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should instantiate the transient Blueprint caller"), BlueprintObject))
	{
		return false;
	}

	UFunction* BlueprintFunction = BlueprintObject->FindFunction(BlueprintInvocationFunctionName);
	if (!TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose the Blueprint caller function on the transient object"), BlueprintFunction))
	{
		return false;
	}

	TAtomic<bool> bMonitorReady(false);
	TAtomic<bool> bShouldStop(false);
	TFuture<FBlueprintFrameMonitorResult> MonitorFuture =
		StartBlueprintFrameMonitor(Session.GetPort(), bMonitorReady, bShouldStop, Session.GetDefaultTimeoutSeconds());
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
	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should bring the monitor client up before execution"), bMonitorStarted))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Id = 46;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("BlueprintScriptBreakLine"));

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should send the script breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForBlueprintBreakpointCount(*this, Session, 1, TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should observe the breakpoint registration after both debugger clients finish handshaking")))
	{
		return false;
	}

	const TSharedRef<FAsyncGeneratedVoidInvocationState> InvocationState =
		DispatchGeneratedVoidInvocation(Engine, BlueprintObject, BlueprintFunction);
	if (!WaitForVoidInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should finish the Blueprint invocation after the monitor resumes execution")))
	{
		return false;
	}

	bShouldStop = true;
	const FBlueprintFrameMonitorResult MonitorResult = MonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should finish without monitor errors"), MonitorResult.Error.IsEmpty()))
	{
		AddError(MonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should not time out while collecting debugger payloads"), MonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should finish the Blueprint caller invocation successfully"), InvocationState->bSucceeded))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should deserialize the stop payload"), MonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should capture a mixed callstack"), MonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should capture the Blueprint-frame ScriptValue evaluation"), MonitorResult.BlueprintScriptValue.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should capture the Blueprint-frame %this% scope"), MonitorResult.BlueprintThisScope.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& Callstack = MonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should return at least two frames"), Callstack.Frames.Num() >= 2))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should locate a Blueprint frame inside the mixed callstack"), Callstack.Frames.IsValidIndex(MonitorResult.BlueprintFrameIndex)))
	{
		return false;
	}

	const FAngelscriptCallFrame& ScriptFrame = Callstack.Frames[0];
	const FAngelscriptCallFrame& BlueprintFrame = Callstack.Frames[MonitorResult.BlueprintFrameIndex];

	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should stop because of a breakpoint"), MonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should keep the script frame on top of the mixed callstack"), ScriptFrame.Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should report the script breakpoint line on the top frame"), ScriptFrame.LineNumber, Fixture.GetLine(TEXT("BlueprintScriptBreakLine")));
	TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should tag the Blueprint caller frame with the (BP) prefix"), BlueprintFrame.Name.StartsWith(TEXT("(BP)")));
	TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should report the Blueprint caller source as a transient outer/class path"), BlueprintFrame.Source.StartsWith(TEXT("::")));
	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should evaluate Blueprint-frame ScriptValue to 5"), MonitorResult.BlueprintScriptValue->Value, FString(TEXT("5")));
	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should observe a single HasContinued after resuming"), MonitorResult.ContinuedCount, 1);

	const TArray<FAngelscriptVariable>& BlueprintThisVariables = MonitorResult.BlueprintThisScope->Variables;
	const FAngelscriptVariable* ScriptValueVariable = BlueprintThisVariables.FindByPredicate(
		[](const FAngelscriptVariable& Variable)
		{
			return Variable.Name == TEXT("ScriptValue");
		});
	if (!TestNotNull(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose ScriptValue inside the Blueprint-frame %this% scope"), ScriptValueVariable))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should report ScriptValue = 5 inside the Blueprint-frame %this% scope"), ScriptValueVariable->Value, FString(TEXT("5")));
	TestTrue(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should expose a non-zero ValueAddress for ScriptValue inside the Blueprint-frame %this% scope"), ScriptValueVariable->ValueAddress != 0);

	int32 LastBreakResult = INDEX_NONE;
	if (!ReadIntProperty(*this, *BlueprintObject, LastBreakResultPropertyName, LastBreakResult, TEXT("Debugger.Blueprint.MixedCallstackAndThisScope")))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Blueprint.MixedCallstackAndThisScope should preserve the expected script-side result after the Blueprint caller resumes"), LastBreakResult, 12);
	return !HasAnyErrors();
}

#endif

