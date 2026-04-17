#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptScriptExamples
{
	const FScriptExampleSource& GetScriptExampleEnumSource()
	{
		static const FScriptExampleSource Example = {
			TEXT("Example_Enum.as"),
			TEXT(R"ANGELSCRIPT(/*
 * All enums from angelscript get bound to unreal by default,
 * nothing special is needed.
 */
enum EExampleEnum_UnitTest
{
	A,
	B,
	C
};

/*
 * Enums can of course be taken as arguments to functions,
 * set as properties, whatever.
 */
UFUNCTION()
void TestExampleEnum_UnitTest(EExampleEnum_UnitTest Input)
{
	switch (Input)
	{
	case EExampleEnum_UnitTest::A:
		Print("You selected A!", Duration=30);
	break;
	case EExampleEnum_UnitTest::B:
		Print("You shouldn't select B.", Duration=30);
	break;
	case EExampleEnum_UnitTest::C:
		Print("What is this even?", Duration=30);
	break;
	}

	// You can cast an int to the enum thus:
	EExampleEnum_UnitTest NumberAsEnum = EExampleEnum_UnitTest(0);
})ANGELSCRIPT"),
			nullptr,
			nullptr,
		};

		return Example;
	}
}

using namespace AngelscriptScriptExamples;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleEnumTest, "Angelscript.TestModule.ScriptExamples.Enum", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleEnumTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, AngelscriptScriptExamples::GetScriptExampleEnumSource());
}

#endif
