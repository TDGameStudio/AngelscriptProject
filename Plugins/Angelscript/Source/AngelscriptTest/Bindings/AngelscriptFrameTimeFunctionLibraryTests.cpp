#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/QualifiedFrameTime.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFrameTimeAsSecondsFunctionLibraryTest,
	"Angelscript.TestModule.FunctionLibraries.FrameTimeAsSeconds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-binding): FFrameRate::AsFrameTime(float) signature removed or changed in UE 5.7; update binding or test script

namespace AngelscriptTest_Bindings_AngelscriptFrameTimeFunctionLibraryTests_Private
{
	static constexpr ANSICHAR FrameTimeBindingsModuleName[] = "ASFrameTimeAsSeconds";
	static constexpr double FrameTimeTolerance = 0.000000001;

	struct FFrameTimeAsSecondsCase
	{
		const TCHAR* Label = TEXT("");
		FQualifiedFrameTime Value;
		double ExpectedSeconds = 0.0;
	};

	TArray<FFrameTimeAsSecondsCase> BuildNativeCases()
	{
		return {
			{ TEXT("48 @ 24fps"), FQualifiedFrameTime(FFrameTime(48), FFrameRate(24, 1)), 2.0 },
			{ TEXT("90 @ 30fps"), FQualifiedFrameTime(FFrameTime(90), FFrameRate(30, 1)), 3.0 },
			{ TEXT("12.5 @ 25fps"), FQualifiedFrameTime(FFrameTime(FFrameNumber(12), 0.5f), FFrameRate(25, 1)), 0.5 }
		};
	}

	FString BuildScriptSource()
	{
	return TEXT(R"(
bool NearlyEqual(float64 Observed, float64 Expected, float64 Tolerance)
{
	return Observed >= Expected - Tolerance && Observed <= Expected + Tolerance;
}

FFrameRate MakeRate(int Numerator, int Denominator)
{
	FFrameRate Rate;
	Rate.Numerator = Numerator;
	Rate.Denominator = Denominator;
	return Rate;
}

FFrameTime MakeWholeFrameTime(int FrameNumber)
{
	FFrameTime Time;
	Time.FrameNumber.Value = FrameNumber;
	return Time;
}

int Entry()
{
	FQualifiedFrameTime IntegerAt24;
	IntegerAt24.Rate = MakeRate(24, 1);
	IntegerAt24.Time = MakeWholeFrameTime(48);
	if (!NearlyEqual(IntegerAt24.AsSeconds(), 2.0, 0.000000001))
		return 10;

	FQualifiedFrameTime IntegerAt30;
	IntegerAt30.Rate = MakeRate(30, 1);
	IntegerAt30.Time = MakeWholeFrameTime(90);
	if (!NearlyEqual(IntegerAt30.AsSeconds(), 3.0, 0.000000001))
		return 20;

	FQualifiedFrameTime FractionalAt25;
	FractionalAt25.Rate = MakeRate(25, 1);
	FractionalAt25.Time = FractionalAt25.Rate.AsFrameTime(0.5);
	if (!NearlyEqual(FractionalAt25.AsSeconds(), 0.6, 0.000000001))
		return 30;

	return 1;
}
)");
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptFrameTimeFunctionLibraryTests_Private;

bool FAngelscriptFrameTimeAsSecondsFunctionLibraryTest::RunTest(const FString& Parameters)
{
	const TArray<FFrameTimeAsSecondsCase> NativeCases = BuildNativeCases();
	bool bNativeBaselinesMatch = true;
	for (const FFrameTimeAsSecondsCase& TestCase : NativeCases)
	{
		bNativeBaselinesMatch &= TestTrue(
			FString::Printf(TEXT("Native %s baseline should match the expected seconds conversion"), TestCase.Label),
			FMath::IsNearlyEqual(TestCase.Value.AsSeconds(), TestCase.ExpectedSeconds, FrameTimeTolerance));
	}
	if (!bNativeBaselinesMatch)
	{
		return false;
	}

	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASFrameTimeAsSeconds"));
	};

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, FrameTimeBindingsModuleName, BuildScriptSource(), TEXT("int Entry()"), Result);

	bPassed = TestEqual(
		TEXT("FQualifiedFrameTime.AsSeconds should preserve integer-frame and sub-frame conversion parity"),
		Result,
		1);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
