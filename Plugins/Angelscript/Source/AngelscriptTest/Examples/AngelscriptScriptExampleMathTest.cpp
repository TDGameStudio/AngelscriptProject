#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleMathTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GMathExample = {
		TEXT("Example_Math.as"),
		TEXT(R"ANGELSCRIPT(/**
 * Core math functions live inside the `Math::` namespace.
 *
 * This lists just a few examples of commonly used math functions.
 */
void ExecuteExampleMath()
{
	float AbsoluteValue = Math::Abs(-1.0);
	check(AbsoluteValue == 1.0);

	float MinimumValue = Math::Min(0.1, 1.0);
	check(MinimumValue == 0.1);

	float MaximumValue = Math::Max(0.1, 1.0);
	check(MaximumValue == 1.0);

	float ClampedValue = Math::Clamp(X = 2.0, Min = 0.0, Max = 0.5);
	check(ClampedValue == 0.5);

	// Create a sine wave based on the current game time
	float WaveValue = Math::Sin(1.0f * 2.0);

	// Generates a random float between two values
	float RandomValue = Math::RandRange(0.0, 10.0);
})ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleMathTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleMathTest, "Angelscript.TestModule.ScriptExamples.Math", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleMathTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GMathExample);
}

#endif
