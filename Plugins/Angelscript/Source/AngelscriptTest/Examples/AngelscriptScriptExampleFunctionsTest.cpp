#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleFunctionsTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GFunctionsExample = {
		TEXT("Example_Functions.as"),
		TEXT(R"ANGELSCRIPT(/*
 * Script functions declared with UFUNCTION() above them will be exposed
 * to unreal. For global functions, this means they will be directly
 * accessible as blueprint nodes.
 */

/*
	The comment directly above the function will be used as a tooltip
	for the blueprint node.

	Note the 'Category = ' specifier in the UFUNCTION() description,
	which will determine the heading the function is under in the
	blueprint menu.
*/

UFUNCTION(Category = "Example Functions")
void ExecuteExampleFunction(AActor InputActor)
{
	Print("Printed on screen");
	Print("Called for actor: " + InputActor.GetName());
}

class AExampleFunctionActor_UnitTest : AActor
{
	/*
	 * In order to declare a new event that can be overriden by
	 * blueprints deriving from this script class, we can use the
	 * BlueprintEvent specifier on the method.
	 *
	 * Note that there is no ImplementableEvent/NativeEvent difference
	 * here either. The script method will be called as a default if
	 * there is no blueprint override, otherwise the blueprint method will
	 * be called.
	 */

	UFUNCTION(BlueprintEvent)
	void NewOverridableMethod()
	{
		Log("Blueprint did not override this event.");
	}
};


/**
 * Parameters can be marked with &out to indicate that they are output
 * references. When called in blueprint, the parameter will appear as
 * an output pin on the right side of the node.
 */
UFUNCTION(Category = "Example Functions")
void ExampleFunctionWithOutputParameter(FVector&out OutPosition)
{
	OutPosition = FVector(1.0, 1.0, 0.0);
})ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleFunctionsTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleFunctionsTest, "Angelscript.TestModule.ScriptExamples.Functions", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleFunctionsTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GFunctionsExample);
}

#endif
