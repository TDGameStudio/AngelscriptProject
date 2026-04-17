#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"
#include "Templates/Function.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayEffectSpecNullDefGuardBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayEffectSpecNullDefGuard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagBlueprintPropertyMapInitializeNullGuardsBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagBlueprintPropertyMapInitializeNullGuards",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptGASValueBindingsTests_Private
{
	static constexpr ANSICHAR GameplayEffectSpecNullDefGuardModuleName[] = "ASGameplayEffectSpecNullDefGuard";
	static constexpr ANSICHAR GameplayTagBlueprintPropertyMapNullGuardsModuleName[] = "ASGameplayTagBlueprintPropertyMapInitializeNullGuards";

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

	bool ExecuteFunctionExpectingScriptException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
		const TCHAR* ContextLabel,
		const TCHAR* ExpectedException,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		FString* OutExceptionString = nullptr)
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
		const FString ExceptionString = UTF8_TO_TCHAR(
			Context->GetExceptionString() != nullptr ? Context->GetExceptionString() : "");
		const int32 ExceptionLine = Context->GetExceptionLineNumber();

		const bool bThrew = Test.TestEqual(
			*FString::Printf(TEXT("%s should fail as a script execution exception instead of crashing"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION));
		const bool bHasMessage = Test.TestTrue(
			*FString::Printf(TEXT("%s should report the expected exception message"), ContextLabel),
			ExceptionString.Contains(ExpectedException));
		const bool bHasLine = Test.TestTrue(
			*FString::Printf(TEXT("%s should report a positive exception line"), ContextLabel),
			ExceptionLine > 0);

		if (OutExceptionString != nullptr)
		{
			*OutExceptionString = ExceptionString;
		}

		return bThrew && bHasMessage && bHasLine;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptGASValueBindingsTests_Private;

bool FAngelscriptGameplayEffectSpecNullDefGuardBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	AddExpectedError(TEXT("GameplayEffect was null."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASGameplayEffectSpecNullDefGuard"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("void TriggerNullEffectSpec() | Line 7 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASGameplayEffectSpecNullDefGuard"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		GameplayEffectSpecNullDefGuardModuleName,
		TEXT(R"(
void TriggerNullEffectSpec()
{
	TSubclassOf<UGameplayEffect> EmptyEffectClass;
	UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
	FGameplayEffectContextHandle Context;
	FGameplayEffectSpec Spec(NullEffect, Context, 1.0f);
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	bPassed = ExecuteFunctionExpectingScriptException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerNullEffectSpec()"),
		TEXT("FGameplayEffectSpec null-def constructor"),
		TEXT("GameplayEffect was null."),
		[](asIScriptContext&)
		{
			return true;
		});

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptGameplayTagBlueprintPropertyMapInitializeNullGuardsBindingsTest::RunTest(const FString& Parameters)
{
	AddExpectedError(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null Owner."), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent."), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASGameplayTagBlueprintPropertyMapInitializeNullGuards"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("TriggerNullOwnerAndASC"), EAutomationExpectedErrorFlags::Contains, 0, false);
	AddExpectedError(TEXT("TriggerNullASC"), EAutomationExpectedErrorFlags::Contains, 0, false);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASGameplayTagBlueprintPropertyMapInitializeNullGuards"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		GameplayTagBlueprintPropertyMapNullGuardsModuleName,
		TEXT(R"(
void TriggerNullOwnerAndASC(int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UObject NullOwner;
	UAbilitySystemComponent NullASC;
	Map.Initialize(NullOwner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}

void TriggerNullASC(UObject Owner, int& OutStep)
{
	OutStep = 1;
	FGameplayTagBlueprintPropertyMap Map;
	UAbilitySystemComponent NullASC;
	Map.Initialize(Owner, NullASC);
	OutStep = 2;
	Map.ApplyCurrentTags();
	OutStep = 3;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	int32 NullOwnerStep = 0;
	FString NullOwnerException;
	if (!ExecuteFunctionExpectingScriptException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerNullOwnerAndASC(int& OutStep)"),
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null)"),
			TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null Owner."),
			[this, &NullOwnerStep](asIScriptContext& Context)
			{
				return SetArgAddressChecked(*this, Context, 0, &NullOwnerStep, TEXT("TriggerNullOwnerAndASC"));
			},
			&NullOwnerException))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null) should surface the owner guard message"),
			NullOwnerException,
			FString(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null Owner.")))
		|| !TestEqual(
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(null, null) should stop before post-initialize code runs"),
			NullOwnerStep,
			1))
	{
		return false;
	}

	UObject* Owner = GetTransientPackage();
	if (!TestNotNull(TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should have a non-null owner fixture"), Owner))
	{
		return false;
	}

	int32 NullASCStep = 0;
	FString NullASCException;
	if (!ExecuteFunctionExpectingScriptException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerNullASC(UObject Owner, int& OutStep)"),
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null)"),
			TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent."),
			[this, Owner, &NullASCStep](asIScriptContext& Context)
			{
				return SetArgObjectChecked(*this, Context, 0, Owner, TEXT("TriggerNullASC"))
					&& SetArgAddressChecked(*this, Context, 1, &NullASCStep, TEXT("TriggerNullASC"));
			},
			&NullASCException))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should surface the ASC guard message"),
			NullASCException,
			FString(TEXT("GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent.")))
		|| !TestEqual(
			TEXT("GameplayTagBlueprintPropertyMap.Initialize(this, null) should stop before ApplyCurrentTags runs"),
			NullASCStep,
			1))
	{
		return false;
	}

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
