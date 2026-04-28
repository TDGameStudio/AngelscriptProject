#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInputActionValueMulAssignCompatTest,
	"Angelscript.TestModule.Bindings.InputActionValueMulAssignCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInputActionValueMulAssignCompatTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

		asIScriptModule* Module = BuildModule(
			*this,
			Engine,
			"ASInputActionValueMulAssignCompat",
			TEXT(R"(
int Entry()
{
	FInputActionValue Value(2.0f);
	FInputActionValue Delta(1.0f);

	Value.opMulAssign(0.5f).opMulAssign(0.5f);
	if (Value.GetAxis1D() < 0.49f || Value.GetAxis1D() > 0.51f)
		return 10;

	Value += Delta;
	if (Value.GetAxis1D() < 1.49f || Value.GetAxis1D() > 1.51f)
		return 20;

	if (!Value.IsNonZero())
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

		TestEqual(TEXT("FInputActionValue *= should keep chaining on the original value and preserve later += updates"), Result, 1);

	ASTEST_END_SHARE_CLEAN

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEnhancedInputComponentConstCompatTest,
	"Angelscript.TestModule.Bindings.EnhancedInputComponentConstCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInputDebugKeyBindingExecuteCompatTest,
	"Angelscript.TestModule.Bindings.InputDebugKeyBindingExecuteCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEnhancedInputComponentConstCompatTest::RunTest(const FString& Parameters)
{
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

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

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
			if (!TestFalse(
				FString::Printf(TEXT("const UEnhancedInputComponent should reject %s"), Expectation.MethodName),
				bCompiled))
			{
				return false;
			}

			TestEqual(
				FString::Printf(TEXT("Rejecting const %s should produce a regular compile error"), Expectation.MethodName),
				CompileSummary.CompileResult,
				ECompileResult::Error);
		}

		asIScriptModule* MutableModule = nullptr;
		ASTEST_BUILD_MODULE(
			Engine,
			"ASEnhancedInputComponentMutableCompat",
			TEXT(R"(
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

int Entry()
{
	return 1;
}
)"),
			MutableModule);

		asIScriptFunction* Function = GetFunctionByDecl(*this, *MutableModule, TEXT("int Entry()"));
		if (Function == nullptr)
		{
			return false;
		}

		int32 Result = 0;
		if (!ExecuteIntFunction(*this, Engine, *Function, Result))
		{
			return false;
		}

		TestEqual(TEXT("Mutable UEnhancedInputComponent should still compile and execute a no-op entry"), Result, 1);

	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptInputDebugKeyBindingExecuteCompatTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

		asIScriptModule* Module = BuildModule(
			*this,
			Engine,
			"ASInputDebugKeyBindingExecuteCompat",
			TEXT(R"(
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

int Entry()
{
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

		TestEqual(
			TEXT("FInputDebugKeyBinding.Execute signature should coexist with enhanced-input binding handle helpers and keep the module executable"),
			Result,
			1);

	ASTEST_END_SHARE_CLEAN

	return true;
}

// ============================================================================
// FInputActionValue constructors and axis type accessors
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInputActionValueConstructorsAndAxisTypesTest,
	"Angelscript.TestModule.Bindings.EnhancedInput.InputActionValueConstructorsAndAxisTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInputActionValueConstructorsAndAxisTypesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "InputValueAxisTypes", TEXT(R"AS(
int Entry()
{
	FInputActionValue Val1D = FInputActionValue(5.0f);
	if (Val1D.GetAxis1D() < 4.9f || Val1D.GetAxis1D() > 5.1f)
		return 1;

	FInputActionValue Val2D = FInputActionValue(FVector2D(3.0f, 4.0f));
	FVector2D V2 = Val2D.GetAxis2D();
	if (V2.X < 2.9f || V2.X > 3.1f)
		return 2;
	if (V2.Y < 3.9f || V2.Y > 4.1f)
		return 3;

	FInputActionValue Val3D = FInputActionValue(FVector(1.0f, 2.0f, 3.0f));
	FVector V3 = Val3D.GetAxis3D();
	if (V3.X < 0.9f || V3.X > 1.1f)
		return 4;
	if (V3.Z < 2.9f || V3.Z > 3.1f)
		return 5;

	return 42;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("FInputActionValue constructors and axis accessors should work correctly"), Result, 42);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// FInputActionValue ConvertToType
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInputActionValueConvertToTypeTest,
	"Angelscript.TestModule.Bindings.EnhancedInput.InputActionValueConvertToType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInputActionValueConvertToTypeTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "InputValueConvert", TEXT(R"AS(
int Entry()
{
	FInputActionValue Val3D = FInputActionValue(FVector(7.0f, 8.0f, 9.0f));

	FInputActionValue Converted1D = Val3D.ConvertToType(EInputActionValueType::Axis1D);
	float Axis1 = Converted1D.GetAxis1D();
	if (Axis1 < 6.9f || Axis1 > 7.1f)
		return 1;

	FInputActionValue Converted2D = Val3D.ConvertToType(EInputActionValueType::Axis2D);
	FVector2D Axis2 = Converted2D.GetAxis2D();
	if (Axis2.X < 6.9f || Axis2.X > 7.1f)
		return 2;

	return 42;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("ConvertToType should preserve dimension data correctly"), Result, 42);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// UEnhancedInputComponent BindAction compiles
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEnhancedInputBindActionCompilesTest,
	"Angelscript.TestModule.Bindings.EnhancedInput.EnhancedInputComponentBindActionCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEnhancedInputBindActionCompilesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "EIBindAction", TEXT(R"AS(
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

int Entry()
{
	return 1;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("BindAction with delegate signature should compile"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// UEnhancedInputComponent RemoveBinding compiles
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEnhancedInputRemoveBindingCompilesTest,
	"Angelscript.TestModule.Bindings.EnhancedInput.EnhancedInputComponentRemoveBindingCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEnhancedInputRemoveBindingCompilesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "EIRemoveBinding", TEXT(R"AS(
void VerifyRemoveSignatures(UEnhancedInputComponent Comp)
{
	Comp.ClearActionEventBindings();
	Comp.ClearActionValueBindings();
	Comp.ClearDebugKeyBindings();
	Comp.ClearActionBindings();
}

int Entry()
{
	return 1;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("Remove/Clear binding signatures should compile"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// UEnhancedInputComponent editor delegate flags
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEnhancedInputEditorDelegateFlagsTest,
	"Angelscript.TestModule.Bindings.EnhancedInput.EnhancedInputComponentEditorDelegateFlags",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEnhancedInputEditorDelegateFlagsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "EIEditorFlags", TEXT(R"AS(
void VerifyEditorDelegateFlags(UEnhancedInputComponent Comp)
{
	Comp.SetShouldFireDelegatesInEditor(true);
	bool bFires = Comp.ShouldFireDelegatesInEditor();
}

int Entry()
{
	return 1;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("Editor delegate flag API should compile"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
