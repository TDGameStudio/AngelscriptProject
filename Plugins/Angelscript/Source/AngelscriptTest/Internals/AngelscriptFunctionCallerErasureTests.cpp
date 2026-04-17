#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../../AngelscriptRuntime/Core/FunctionCallers.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptFunctionCallerErasureTests_Private
{
	struct FConstRefQualifiedProbe
	{
		int32 Base = 11;

		int32 ReadPlus(int32 Delta) const&
		{
			return Base + Delta;
		}
	};

	template <typename MethodType>
	ASAutoCaller::TMethodPtr MakeErasedMethodPointer(MethodType Method)
	{
		const FGenericFuncPtr GenericMethod = MakeAutoMethodPtr(Method);
		ASAutoCaller::TMethodPtr ErasedMethod = nullptr;
		FMemory::Memcpy(&ErasedMethod, GenericMethod.ptr.dummy, sizeof(ErasedMethod));
		return ErasedMethod;
	}
}

using namespace AngelscriptTest_Internals_AngelscriptFunctionCallerErasureTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFunctionCallersConstRefQualifiedMethodCallerTest,
	"Angelscript.TestModule.Internals.FunctionCallers.ConstRefQualifiedMethodCaller",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptFunctionCallersConstRefQualifiedMethodCallerTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	using FProbeMethod = int32 (FConstRefQualifiedProbe::*)(int32) const&;
	const FProbeMethod Method = &FConstRefQualifiedProbe::ReadPlus;

	FGenericFuncPtr GenericMethod = MakeAutoMethodPtr(Method);
	const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(Method);
	ASAutoCaller::TMethodPtr ErasedMethod = MakeErasedMethodPointer(Method);

	bPassed &= TestTrue(TEXT("const& qualified method caller should produce a bound generic method pointer"), GenericMethod.IsBound());
	bPassed &= TestEqual(TEXT("const& qualified method caller should encode the method pointer as a class method"), static_cast<int32>(GenericMethod.flag), 3);
	bPassed &= TestTrue(TEXT("const& qualified method caller should produce a bound auto caller"), Caller.IsBound());
	bPassed &= TestEqual(TEXT("const& qualified method caller should select the method caller path"), Caller.type, 2);

	FConstRefQualifiedProbe Probe;
	int32 Delta = 5;
	int32 Result = 0;
	void* Arguments[] =
	{
		&Probe,
		&Delta,
	};

	Caller.MethodPtr(ErasedMethod, Arguments, &Result);

	bPassed &= TestEqual(TEXT("const& qualified method caller should preserve the erased return value"), Result, 16);
	bPassed &= TestEqual(TEXT("const& qualified method caller should not mutate the probe object"), Probe.Base, 11);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
