#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Phase 4 tests — script interface method UFUNCTION specifiers now propagate
// to the generated interface UFunction's FunctionFlags:
//   - BlueprintNativeEvent      → FUNC_Event | FUNC_BlueprintEvent | FUNC_Native
//   - BlueprintImplementableEvent → FUNC_Event | FUNC_BlueprintEvent (no FUNC_Native)
//   - BlueprintCallable         → adds FUNC_BlueprintCallable
//   - BlueprintPure             → adds FUNC_BlueprintPure | FUNC_BlueprintCallable
//   - No UFUNCTION macro        → baseline FUNC_Event | FUNC_BlueprintEvent
//
// These tests compile a script-defined UINTERFACE, locate the generated UClass
// for the interface, and inspect the UFunctions' FunctionFlags to verify the
// specifiers were honored end-to-end (preprocessor → ClassGenerator).
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInterfaceEventFlagsMatrixTest,
	"Angelscript.TestModule.Interface.EventFlags.Matrix",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInterfaceEventFlagsMatrixTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	do
	{

	static const FName ModuleName(TEXT("TestInterfaceEventFlagsMatrix"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	// Compile a single interface that exercises every specifier combination
	// Phase 4 recognizes. The module also contains a conforming implementation
	// class so that FinalizeClass's structural-signature check (Phase 1) has
	// work to do — BlueprintNativeEvent + BlueprintImplementableEvent methods
	// must not gain FUNC_Native-induced mismatch errors against the script-side
	// `_Implementation`-less override form (AS uses the bare declaration as
	// the override path).
	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestInterfaceEventFlagsMatrix.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIEventFlagsMatrix
{
	void PlainMethod();

	UFUNCTION(BlueprintNativeEvent)
	void NativeEventMethod();

	UFUNCTION(BlueprintImplementableEvent)
	void ImplementableEventMethod();

	UFUNCTION(BlueprintCallable)
	int CallableGetter();

	UFUNCTION(BlueprintPure)
	int PureGetter();
}

UCLASS()
class ATestEventFlagsMatrix : AActor, UIEventFlagsMatrix
{
	UFUNCTION()
	void PlainMethod() {}

	UFUNCTION()
	void NativeEventMethod() {}

	UFUNCTION()
	void ImplementableEventMethod() {}

	UFUNCTION()
	int CallableGetter() { return 1; }

	UFUNCTION()
	int PureGetter() { return 2; }
}
)AS"),
		TEXT("ATestEventFlagsMatrix"));

	if (!TestNotNull(TEXT("Implementation class should compile when all interface signatures match"), ScriptClass))
	{
		break;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIEventFlagsMatrix"));
	if (!TestNotNull(TEXT("Interface UClass should be generated"), InterfaceClass))
	{
		break;
	}

	auto GetInterfaceMethodFlags = [InterfaceClass](const TCHAR* FuncName) -> uint32
	{
		UFunction* Func = InterfaceClass->FindFunctionByName(FName(FuncName));
		return Func != nullptr ? (uint32)Func->FunctionFlags : 0;
	};

	// ---- PlainMethod: baseline (no UFUNCTION) ----
	const uint32 PlainFlags = GetInterfaceMethodFlags(TEXT("PlainMethod"));
	TestTrue(TEXT("PlainMethod should carry FUNC_Event"), (PlainFlags & FUNC_Event) != 0);
	TestTrue(TEXT("PlainMethod should carry FUNC_BlueprintEvent"), (PlainFlags & FUNC_BlueprintEvent) != 0);
	TestTrue(TEXT("PlainMethod should NOT carry FUNC_Native (implementable only)"), (PlainFlags & FUNC_Native) == 0);
	TestTrue(TEXT("PlainMethod should carry FUNC_Public"), (PlainFlags & FUNC_Public) != 0);

	// ---- NativeEventMethod: BlueprintNativeEvent ----
	const uint32 NativeFlags = GetInterfaceMethodFlags(TEXT("NativeEventMethod"));
	TestTrue(TEXT("NativeEventMethod should carry FUNC_Event"), (NativeFlags & FUNC_Event) != 0);
	TestTrue(TEXT("NativeEventMethod should carry FUNC_BlueprintEvent"), (NativeFlags & FUNC_BlueprintEvent) != 0);
	TestTrue(TEXT("NativeEventMethod should carry FUNC_Native"), (NativeFlags & FUNC_Native) != 0);
	TestTrue(TEXT("NativeEventMethod should carry FUNC_Public"), (NativeFlags & FUNC_Public) != 0);

	// ---- ImplementableEventMethod: BlueprintImplementableEvent ----
	const uint32 ImplementableFlags = GetInterfaceMethodFlags(TEXT("ImplementableEventMethod"));
	TestTrue(TEXT("ImplementableEventMethod should carry FUNC_Event"), (ImplementableFlags & FUNC_Event) != 0);
	TestTrue(TEXT("ImplementableEventMethod should carry FUNC_BlueprintEvent"), (ImplementableFlags & FUNC_BlueprintEvent) != 0);
	TestTrue(TEXT("ImplementableEventMethod should NOT carry FUNC_Native"), (ImplementableFlags & FUNC_Native) == 0);

	// ---- CallableGetter: BlueprintCallable ----
	const uint32 CallableFlags = GetInterfaceMethodFlags(TEXT("CallableGetter"));
	TestTrue(TEXT("CallableGetter should carry FUNC_BlueprintCallable"), (CallableFlags & FUNC_BlueprintCallable) != 0);

	// ---- PureGetter: BlueprintPure ----
	const uint32 PureFlags = GetInterfaceMethodFlags(TEXT("PureGetter"));
	TestTrue(TEXT("PureGetter should carry FUNC_BlueprintPure"), (PureFlags & FUNC_BlueprintPure) != 0);
	TestTrue(TEXT("PureGetter should carry FUNC_BlueprintCallable (Pure implies Callable)"), (PureFlags & FUNC_BlueprintCallable) != 0);

	}
	while (false);
	ASTEST_END_SHARE_FRESH
	return !HasAnyErrors();
}

#endif
