#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "GameFramework/Actor.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptClassBindingsTests_Private
{
	static constexpr ANSICHAR TSubclassOfRejectsUnrelatedClassModuleName[] = "ASTSubclassOfRejectsUnrelatedClass";

	bool SetArgAddressChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Address,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind address argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgAddress(ArgumentIndex, Address),
			static_cast<int32>(asSUCCESS));
	}

	bool SetArgObjectChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Object,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind object argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgObject(ArgumentIndex, Object),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteFunctionExpectingSuccess(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			Context->Execute(),
			static_cast<int32>(asEXECUTION_FINISHED));
	}

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		FString& OutExceptionString)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptClassBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptClassLookupBindingsTest,
	"Angelscript.TestModule.Bindings.ClassLookupCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTSubclassOfBindingsTest,
	"Angelscript.TestModule.Bindings.TSubclassOfCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTSubclassOfRejectsUnrelatedClassBindingsTest,
	"Angelscript.TestModule.Bindings.TSubclassOfRejectsUnrelatedClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTSoftClassPtrBindingsTest,
	"Angelscript.TestModule.Bindings.TSoftClassPtrCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStaticClassCompatBindingsTest,
	"Angelscript.TestModule.Bindings.StaticClassCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeStaticClassNamespaceBindingTest,
	"Angelscript.TestModule.Bindings.NativeStaticClassNamespace",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeStaticTypeGlobalBindingTest,
	"Angelscript.TestModule.Bindings.NativeStaticTypeGlobal",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptClassLookupBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASClassLookupCompat",
		TEXT(R"(
int Entry()
{
	UClass ActorClass = FindClass("AActor");
	if (ActorClass == null)
		return 10;

	TArray<UClass> AllClasses;
	GetAllClasses(AllClasses);
	if (AllClasses.Num() <= 0)
		return 20;

	bool bFoundActor = false;
	for (int Index = 0; Index < AllClasses.Num(); ++Index)
	{
		if (AllClasses[Index] == ActorClass)
		{
			bFoundActor = true;
			break;
		}
	}

	if (!bFoundActor)
		return 30;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("Class lookup helper operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptTSubclassOfBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASTSubclassOfCompat",
		TEXT(R"(
TSubclassOf<AActor> EchoSubclass(TSubclassOf<AActor> Value)
{
	return Value;
}

UClass EchoSubclassClass(TSubclassOf<AActor> Value)
{
	return Value;
}

int Entry()
{
	TSubclassOf<AActor> Empty;
	if (Empty.IsValid())
		return 10;
	if (!(Empty.Get() == null))
		return 20;

	Empty = AActor::StaticClass();
	if (!Empty.IsValid())
		return 30;
	if (!(Empty.Get() == AActor::StaticClass()))
		return 40;
	if (!(Empty == AActor::StaticClass()))
		return 50;

	TSubclassOf<AActor> ImplicitFromClassArg = EchoSubclass(AActor::StaticClass());
	if (!(ImplicitFromClassArg == AActor::StaticClass()))
		return 55;

	UClass ImplicitClassArg = EchoSubclassClass(ACameraActor::StaticClass());
	if (!(ImplicitClassArg == ACameraActor::StaticClass()))
		return 56;

	TSubclassOf<AActor> Narrowed = ACameraActor::StaticClass();
	TSubclassOf<AActor> Copy = Narrowed;
	if (!(Copy == ACameraActor::StaticClass()))
		return 60;

	AActor DefaultActor = Copy.GetDefaultObject();
	if (!IsValid(DefaultActor))
		return 70;
	if (!DefaultActor.IsA(ACameraActor::StaticClass()))
		return 80;

	TArray<TSubclassOf<AActor>> LiteralSubclassHistory;
	LiteralSubclassHistory.Add(AActor::StaticClass());
	LiteralSubclassHistory.Add(ACameraActor::StaticClass());
	if (LiteralSubclassHistory.Num() != 2)
		return 90;
	if (!(LiteralSubclassHistory[1] == ACameraActor::StaticClass()))
		return 100;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("TSubclassOf compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptTSubclassOfRejectsUnrelatedClassBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("Class set to TSubclassOf<> was not a child of templated class."), EAutomationExpectedErrorFlags::Contains, 2);
	AddExpectedError(TEXT("ASTSubclassOfRejectsUnrelatedClass"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("TriggerInvalidImplicitCtor"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("AssignClass"), EAutomationExpectedErrorFlags::Contains, 0);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASTSubclassOfRejectsUnrelatedClass"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		TSubclassOfRejectsUnrelatedClassModuleName,
		TEXT(R"(
void TriggerInvalidImplicitCtor()
{
	TSubclassOf<AActor> Invalid = UPackage::StaticClass();
}

void AssignClass(TSubclassOf<AActor>& OutValue, UClass NewClass)
{
	OutValue = NewClass;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	TSubclassOf<AActor> ResetTarget = AActor::StaticClass();
	if (!ExecuteFunctionExpectingSuccess(
		*this,
		Engine,
		*Module,
		TEXT("void AssignClass(TSubclassOf<AActor>& OutValue, UClass NewClass)"),
		[this, &ResetTarget](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &ResetTarget, TEXT("AssignClass(null)"))
				&& SetArgObjectChecked(*this, Context, 1, nullptr, TEXT("AssignClass(null)"));
		},
		TEXT("AssignClass(null)")))
	{
		return false;
	}

	bPassed &= TestFalse(
		TEXT("TSubclassOf assignment from a null UClass should reset the destination to an invalid state"),
		ResetTarget.Get() != nullptr);
	bPassed &= TestNull(
		TEXT("TSubclassOf assignment from a null UClass should clear the stored class pointer"),
		ResetTarget.Get());
	bPassed &= TestNull(
		TEXT("TSubclassOf assignment from a null UClass should clear the default object path"),
		ResetTarget.GetDefaultObject());

	FString InvalidCtorExceptionString;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerInvalidImplicitCtor()"),
		[](asIScriptContext& Context)
		{
			return true;
		},
		TEXT("TriggerInvalidImplicitCtor"),
		InvalidCtorExceptionString))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("TSubclassOf implicit construction from an unrelated UClass should report the expected diagnostic"),
		InvalidCtorExceptionString.Contains(TEXT("Class set to TSubclassOf<> was not a child of templated class.")));

	TSubclassOf<AActor> AssignmentTarget = AActor::StaticClass();
	FString InvalidAssignmentExceptionString;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("void AssignClass(TSubclassOf<AActor>& OutValue, UClass NewClass)"),
		[this, &AssignmentTarget](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &AssignmentTarget, TEXT("AssignClass(invalid)"))
				&& SetArgObjectChecked(*this, Context, 1, UPackage::StaticClass(), TEXT("AssignClass(invalid)"));
		},
		TEXT("AssignClass(invalid)"),
		InvalidAssignmentExceptionString))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("TSubclassOf assignment from an unrelated UClass should report the expected diagnostic"),
		InvalidAssignmentExceptionString.Contains(TEXT("Class set to TSubclassOf<> was not a child of templated class.")));
	bPassed &= TestFalse(
		TEXT("TSubclassOf assignment from an unrelated UClass should reset the destination to an invalid state"),
		AssignmentTarget.Get() != nullptr);
	bPassed &= TestNull(
		TEXT("TSubclassOf assignment from an unrelated UClass should clear the stored class pointer"),
		AssignmentTarget.Get());
	bPassed &= TestNull(
		TEXT("TSubclassOf assignment from an unrelated UClass should clear the default object path"),
		AssignmentTarget.GetDefaultObject());

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptTSoftClassPtrBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASTSoftClassPtrCompat",
		TEXT(R"(
TSoftClassPtr<AActor> EchoSoftClass(TSoftClassPtr<AActor> Value)
{
	return Value;
}

UClass EchoSoftClassClass(TSoftClassPtr<AActor> Value)
{
	return Value.Get();
}

int Entry()
{
	TSoftClassPtr<AActor> Empty;
	if (!Empty.IsNull())
		return 10;
	if (Empty.IsValid())
		return 20;

	TSoftClassPtr<AActor> Constructed(AActor::StaticClass());
	if (!(Constructed == AActor::StaticClass()))
		return 30;
	if (!(Constructed.Get() == AActor::StaticClass()))
		return 40;
	if (!(Constructed.Get() == AActor::StaticClass()))
		return 50;
	if (!Constructed.IsValid())
		return 60;
	if (Constructed.ToString().IsEmpty())
		return 70;

	TSoftClassPtr<AActor> ImplicitFromClassArg = EchoSoftClass(TSoftClassPtr<AActor>(AActor::StaticClass()));
	if (!(ImplicitFromClassArg == AActor::StaticClass()))
		return 80;

	UClass ImplicitClassArg = EchoSoftClassClass(TSoftClassPtr<AActor>(ACameraActor::StaticClass()));
	if (!(ImplicitClassArg == ACameraActor::StaticClass()))
		return 90;

	TSoftClassPtr<AActor> Assigned;
	Assigned = AActor::StaticClass();
	if (!(Assigned == AActor::StaticClass()))
		return 100;

	TArray<TSoftClassPtr<AActor>> LiteralHistory;
	LiteralHistory.Add(TSoftClassPtr<AActor>(AActor::StaticClass()));
	LiteralHistory.Add(TSoftClassPtr<AActor>(ACameraActor::StaticClass()));
	if (LiteralHistory.Num() != 2)
		return 110;
	if (!(LiteralHistory[1] == ACameraActor::StaticClass()))
		return 120;

	Assigned.Reset();
	if (!Assigned.IsNull())
		return 130;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("TSoftClassPtr compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptStaticClassCompatBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	asIScriptModule* PlainModule = BuildModule(
		*this,
		Engine,
		"ASStaticClassCompat",
		TEXT(R"(
int Entry()
{
	UClass ActorClass = AActor::StaticClass();
	TSubclassOf<AActor> CompatClass = AActor::StaticClass();

	if (!IsValid(ActorClass) || !CompatClass.IsValid())
		return 10;
	if (!ActorClass.IsChildOf(CompatClass) || !CompatClass.IsChildOf(ActorClass))
		return 20;
	if (!IsValid(ActorClass.GetDefaultObject()))
		return 30;

	return 1;
}
)"));
	if (PlainModule == nullptr)
	{
		return false;
	}

	asIScriptFunction* PlainFunction = GetFunctionByDecl(*this, *PlainModule, TEXT("int Entry()"));
	if (PlainFunction == nullptr)
	{
		return false;
	}

	int32 PlainResult = 0;
	if (!ExecuteIntFunction(*this, Engine, *PlainFunction, PlainResult))
	{
		return false;
	}
	if (!TestEqual(TEXT("Plain module StaticClass and TSubclassOf compat syntax should behave as expected"), PlainResult, 1))
	{
		return false;
	}
	const bool bAnnotatedCompiled = CompileAnnotatedModuleFromMemory(
		&Engine,
		TEXT("ASAnnotatedStaticClassCompat"),
		TEXT("ASAnnotatedStaticClassCompat.as"),
		TEXT(R"(
UCLASS()
class ABindingStaticClassActor : AActor
{
	UFUNCTION()
	int ReadStaticClassCompat()
	{
		UClass SelfClass = ABindingStaticClassActor::StaticClass();
		TSubclassOf<ABindingStaticClassActor> CompatClass = ABindingStaticClassActor::StaticClass();

		if (!IsValid(SelfClass) || !CompatClass.IsValid())
			return 10;
		if (!SelfClass.IsChildOf(GetClass()) || !GetClass().IsChildOf(SelfClass))
			return 20;
		if (!CompatClass.IsChildOf(SelfClass) || !SelfClass.IsChildOf(CompatClass))
			return 30;

		return IsValid(SelfClass.GetDefaultObject()) ? 1 : 40;
	}
}

)"));
	if (!TestTrue(TEXT("Annotated StaticClass compat module should compile"), bAnnotatedCompiled))
	{
		return false;
	}

	UClass* RuntimeActorClass = FindGeneratedClass(&Engine, TEXT("ABindingStaticClassActor"));
	if (!TestNotNull(TEXT("Generated actor class for StaticClass compat should exist"), RuntimeActorClass))
	{
		return false;
	}

	UFunction* ReadStaticClassCompatFunction = FindGeneratedFunction(RuntimeActorClass, TEXT("ReadStaticClassCompat"));
	if (!TestNotNull(TEXT("StaticClass compat function should exist"), ReadStaticClassCompatFunction))
	{
		return false;
	}
	AActor* RuntimeActor = NewObject<AActor>(GetTransientPackage(), RuntimeActorClass);
	if (!TestNotNull(TEXT("Generated actor for StaticClass compat should instantiate"), RuntimeActor))
	{
		return false;
	}

	int32 AnnotatedResult = 0;
	if (!TestTrue(TEXT("StaticClass compat reflected call should execute on the game thread"), ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeActor, ReadStaticClassCompatFunction, AnnotatedResult)))
	{
		return false;
	}
	if (!TestEqual(TEXT("Annotated module StaticClass and TSubclassOf compat syntax should behave as expected"), AnnotatedResult, 1))
	{
		return false;
	}

	asIScriptModule* QueryModule = BuildModule(
		*this,
		Engine,
		"ASGeneratedStaticClassQuery",
		TEXT(R"(
int Entry()
{
	UClass SelfClass = FindClass("ABindingStaticClassActor");
	TSubclassOf<AActor> CompatClass = FindClass("ABindingStaticClassActor");

	if (!IsValid(SelfClass) || !CompatClass.IsValid())
		return 10;
	if (!SelfClass.IsChildOf(AActor::StaticClass()))
		return 20;
	if (!CompatClass.IsChildOf(SelfClass) || !SelfClass.IsChildOf(CompatClass))
		return 30;

	return 1;
}
)"));
	if (QueryModule == nullptr)
	{
		return false;
	}

	asIScriptFunction* QueryFunction = GetFunctionByDecl(*this, *QueryModule, TEXT("int Entry()"));
	if (QueryFunction == nullptr)
	{
		return false;
	}

	int32 QueryResult = 0;
	if (!ExecuteIntFunction(*this, Engine, *QueryFunction, QueryResult))
	{
		return false;
	}

	TestEqual(TEXT("Follow-up plain module should resolve generated classes into TSubclassOf compat flow"), QueryResult, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptNativeStaticClassNamespaceBindingTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptEngine* ScriptEngine = Engine.Engine;
	if (!TestNotNull(TEXT("AngelScript engine should exist"), ScriptEngine))
	{
		return false;
	}

	if (!TestTrue(TEXT("Set namespace to AActor should succeed"), ScriptEngine->SetDefaultNamespace("AActor") >= 0))
	{
		return false;
	}

	asIScriptFunction* StaticClassFunction = ScriptEngine->GetGlobalFunctionByDecl("UClass StaticClass()");
	const bool bHasFunction = TestNotNull(TEXT("Native class namespace should expose StaticClass"), StaticClassFunction);

	if (StaticClassFunction != nullptr)
	{
		TestEqual(TEXT("Native class namespace StaticClass should keep bound UClass userdata"), static_cast<UClass*>(StaticClassFunction->GetUserData()), AActor::StaticClass());
	}

	TestTrue(TEXT("Restore global namespace should succeed"), ScriptEngine->SetDefaultNamespace("") >= 0);
	bPassed = bHasFunction;
	ASTEST_END_SHARE

	return bPassed;
}

bool FAngelscriptNativeStaticTypeGlobalBindingTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASNativeStaticTypeGlobal",
		TEXT(R"(
int Entry()
{
	if (!__StaticType_AActor.IsValid())
		return 5;
	if (!(__StaticType_AActor.Get() == AActor::StaticClass()))
		return 7;
	if (!(__StaticType_AActor == AActor::StaticClass()))
		return 10;
	if (!__StaticType_AActor.IsChildOf(AActor::StaticClass()))
		return 20;
	return IsValid(__StaticType_AActor.GetDefaultObject()) ? 1 : 30;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("Native static type globals should expose usable UClass values"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

#endif
