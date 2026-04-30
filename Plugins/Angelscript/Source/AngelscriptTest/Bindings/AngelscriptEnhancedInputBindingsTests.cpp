// ============================================================================
// AngelscriptEnhancedInputBindingsTests.cpp
//
// Enhanced Input binding coverage — CQTest refactor. Automation ID:
//   Angelscript.TestModule.Bindings.EnhancedInput.FAngelscriptEnhancedInputBindingsTest.*
//
// Sections:
//   InputActionValueMulAssignCompat      — *= chaining preserves value
//   EnhancedInputComponentConstCompat    — const rejection + mutable compilation
//   InputDebugKeyBindingExecuteCompat    — binding handle/execute coexistence
//   InputActionValueConstructorsAndAxisTypes — constructors and axis accessors
//   InputActionValueConvertToType        — ConvertToType dimension preservation
//   EnhancedInputComponentBindActionCompiles — BindAction delegate compilation
//   EnhancedInputComponentRemoveBindingCompiles — Clear binding compilation
//   EnhancedInputComponentEditorDelegateFlags — editor delegate flag API
//
// CQTest adaptation notes:
//   Eight IMPLEMENT_SIMPLE_AUTOMATION_TEST merged into one TEST_CLASS.
//   Each section uses FCoverageModuleScope + ExpectGlobalInt where possible.
//   The const-compat test retains its compile-error assertion pattern.
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;
using namespace AngelscriptReflectiveAccess;

static const FBindingsCoverageProfile GEnhInputProfile{
	TEXT("EnhancedInput"), TEXT(""), TEXT("ASEnhInput"), TEXT("EnhInput"), TEXT("EnhancedInputBindings")
};

TEST_CLASS_WITH_FLAGS(FAngelscriptEnhancedInputBindingsTest, "Angelscript.TestModule.Bindings.EnhancedInput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(InputActionValueMulAssignCompat)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("MulAssignCompat"), TEXT(R"(
int MulAssignChaining()
{
	FInputActionValue Value(2.0f);
	FInputActionValue Delta(1.0f);

	Value.opMulAssign(0.5f).opMulAssign(0.5f);
	if (Value.GetAxis1D() < 0.49f || Value.GetAxis1D() > 0.51f)
		return 0;

	Value += Delta;
	if (Value.GetAxis1D() < 1.49f || Value.GetAxis1D() > 1.51f)
		return 0;

	if (!Value.IsNonZero())
		return 0;

	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int MulAssignChaining()"),
			TEXT("*= chaining should preserve value and support later +="), 1);
	}

	TEST_METHOD(EnhancedInputComponentConstCompat)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		struct FConstClearMethodExpectation
		{
			const TCHAR* MethodName = nullptr;
			const TCHAR* ScriptModuleSuffix = nullptr;
			const TCHAR* CallExpression = nullptr;
		};

		static const FConstClearMethodExpectation ConstClearMethods[] =
		{
			{ TEXT("ClearActionEventBindings"), TEXT("ActionEvent"), TEXT("Comp.ClearActionEventBindings();") },
			{ TEXT("ClearActionValueBindings"), TEXT("ActionValue"), TEXT("Comp.ClearActionValueBindings();") },
			{ TEXT("ClearDebugKeyBindings"), TEXT("DebugKey"), TEXT("Comp.ClearDebugKeyBindings();") },
			{ TEXT("ClearActionBindings"), TEXT("ActionBindings"), TEXT("Comp.ClearActionBindings();") },
		};

		for (const FConstClearMethodExpectation& Expectation : ConstClearMethods)
		{
			const FName ModuleName(*FString::Printf(TEXT("ASEnhancedInputComponentConstCompat_%s"), Expectation.ScriptModuleSuffix));
			const FString ScriptFilename = FString::Printf(TEXT("ASEnhancedInputComponentConstCompat_%s.as"), Expectation.ScriptModuleSuffix);
			const FString Script = FString::Printf(TEXT(R"(
bool ReadConst(const UEnhancedInputComponent Comp)
{
	return Comp.HasBindings();
}

void MutateConst(const UEnhancedInputComponent Comp)
{
	%s
}

int Entry()
{
	return 1;
}
)"), Expectation.CallExpression);

			FAngelscriptCompileTraceSummary CompileSummary;
			const bool bCompiled = CompileModuleWithSummary(
				&Engine,
				ECompileType::SoftReloadOnly,
				ModuleName,
				ScriptFilename,
				Script,
				false,
				CompileSummary,
				true);
			if (!TestRunner->TestFalse(
				FString::Printf(TEXT("const UEnhancedInputComponent should reject %s"), Expectation.MethodName),
				bCompiled))
			{
				return;
			}

			TestRunner->TestEqual(
				FString::Printf(TEXT("Rejecting const %s should produce a regular compile error"), Expectation.MethodName),
				CompileSummary.CompileResult,
				ECompileResult::Error);
		}

		// Mutable path should compile and execute
		FCoverageModuleScope MutableMod(*TestRunner, Engine, GEnhInputProfile, TEXT("MutableCompat"), TEXT(R"(
bool ReadConst(const UEnhancedInputComponent Comp)
{
	return Comp.HasBindings();
}

bool MutateMutable(UEnhancedInputComponent Comp)
{
	Comp.ClearActionEventBindings();
	Comp.ClearActionValueBindings();
	Comp.ClearDebugKeyBindings();
	Comp.ClearActionBindings();
	return Comp.HasBindings();
}

int MutableEntry()
{
	return 1;
}
)"));
		if (!MutableMod.IsValid()) return;
		auto& MM = MutableMod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, MM, GEnhInputProfile,
			TEXT("int MutableEntry()"),
			TEXT("Mutable UEnhancedInputComponent should compile and execute"), 1);
	}

	TEST_METHOD(InputDebugKeyBindingExecuteCompat)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("DebugKeyBindingCompat"), TEXT(R"(
int VerifyBindingCompat(
	FEnhancedInputActionEventBinding& EventBinding,
	FEnhancedInputActionValueBinding& ValueBinding,
	FInputDebugKeyBinding& DebugBinding,
	const FInputActionInstance& ActionInstance,
	const FInputActionValue& ActionValue)
{
	const uint EventHandle = EventBinding.GetHandle();
	EventBinding.Execute(ActionInstance);

	const uint ValueHandle = ValueBinding.GetHandle();
	const FInputActionValue CurrentValue = ValueBinding.GetValue();

	const uint DebugHandle = DebugBinding.GetHandle();
	DebugBinding.Execute(ActionValue);

	if (CurrentValue.IsNonZero() && EventHandle == ValueHandle && ValueHandle == DebugHandle)
		return 2;

	return 1;
}

int DebugKeyEntry()
{
	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int DebugKeyEntry()"),
			TEXT("FInputDebugKeyBinding.Execute should coexist with binding handle helpers"), 1);
	}

	TEST_METHOD(InputActionValueConstructorsAndAxisTypes)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("ConstructorsAxisTypes"), TEXT(R"(
int VerifyConstructorsAndAxisTypes()
{
	FInputActionValue Val1D = FInputActionValue(5.0f);
	if (Val1D.GetAxis1D() < 4.9f || Val1D.GetAxis1D() > 5.1f)
		return 0;

	FInputActionValue Val2D = FInputActionValue(FVector2D(3.0f, 4.0f));
	FVector2D V2 = Val2D.GetAxis2D();
	if (V2.X < 2.9f || V2.X > 3.1f)
		return 0;
	if (V2.Y < 3.9f || V2.Y > 4.1f)
		return 0;

	FInputActionValue Val3D = FInputActionValue(FVector(1.0f, 2.0f, 3.0f));
	FVector V3 = Val3D.GetAxis3D();
	if (V3.X < 0.9f || V3.X > 1.1f)
		return 0;
	if (V3.Z < 2.9f || V3.Z > 3.1f)
		return 0;

	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int VerifyConstructorsAndAxisTypes()"),
			TEXT("FInputActionValue constructors and axis accessors should work correctly"), 1);
	}

	TEST_METHOD(InputActionValueConvertToType)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("ConvertToType"), TEXT(R"(
int VerifyConvertToType()
{
	FInputActionValue Val3D = FInputActionValue(FVector(7.0f, 8.0f, 9.0f));

	FInputActionValue Converted1D = Val3D.ConvertToType(EInputActionValueType::Axis1D);
	float Axis1 = Converted1D.GetAxis1D();
	if (Axis1 < 6.9f || Axis1 > 7.1f)
		return 0;

	FInputActionValue Converted2D = Val3D.ConvertToType(EInputActionValueType::Axis2D);
	FVector2D Axis2 = Converted2D.GetAxis2D();
	if (Axis2.X < 6.9f || Axis2.X > 7.1f)
		return 0;

	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int VerifyConvertToType()"),
			TEXT("ConvertToType should preserve dimension data correctly"), 1);
	}

	TEST_METHOD(EnhancedInputComponentBindActionCompiles)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("BindAction"), TEXT(R"(
UCLASS()
class ABindActionTestActor : AActor
{
	UPROPERTY()
	UInputAction InputJump;

	UFUNCTION()
	void OnJumpTriggered(FInputActionValue ActionValue)
	{
	}

	UFUNCTION()
	void SetupInput(UEnhancedInputComponent InputComp)
	{
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, n"OnJumpTriggered");
		InputComp.BindAction(InputJump, ETriggerEvent::Triggered, Delegate);
	}
}

int BindActionEntry()
{
	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int BindActionEntry()"),
			TEXT("BindAction with delegate signature should compile"), 1);
	}

	TEST_METHOD(EnhancedInputComponentRemoveBindingCompiles)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("RemoveBinding"), TEXT(R"(
void VerifyRemoveSignatures(UEnhancedInputComponent Comp)
{
	Comp.ClearActionEventBindings();
	Comp.ClearActionValueBindings();
	Comp.ClearDebugKeyBindings();
	Comp.ClearActionBindings();
}

int RemoveBindingEntry()
{
	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int RemoveBindingEntry()"),
			TEXT("Remove/Clear binding signatures should compile"), 1);
	}

	TEST_METHOD(EnhancedInputComponentEditorDelegateFlags)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GEnhInputProfile, TEXT("EditorDelegateFlags"), TEXT(R"(
void VerifyEditorDelegateFlags(UEnhancedInputComponent Comp)
{
	Comp.SetShouldFireDelegatesInEditor(true);
	bool bFires = Comp.ShouldFireDelegatesInEditor();
}

int EditorFlagsEntry()
{
	return 1;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();
		ExpectGlobalInt(*TestRunner, Engine, M, GEnhInputProfile,
			TEXT("int EditorFlagsEntry()"),
			TEXT("Editor delegate flag API should compile"), 1);
	}
};

#endif
