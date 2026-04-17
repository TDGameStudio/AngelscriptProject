#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleFunctionSpecifiersTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GFunctionSpecifiersExample = {
		TEXT("Example_FunctionSpecifiers.as"),
		TEXT(R"ANGELSCRIPT(class AExampleFunctionSpecifierActor_UnitTest : AActor
{
    /*
        When declaring functions, Function Specifiers can be added to the declaration to control how the function behaves with various aspects of the Engine and Editor.
    */

    // Adding UFUNCTION allows the function to be visible in blueprint, as a non-pure function
    UFUNCTION()
    void BlueprintVisibleFunction()
    {
    }

    /*  BlueprintPure turns the function into a pure function
    *   Pure functions require a return value, for obvious reasons
    */
    UFUNCTION(BlueprintPure)
    bool BlueprintPureFunction()
    {
        return true;
    }

    /* This function will not be callable from outside anglescript
	 * Some functions like Delegate or timer functions need to have a UFUNCTION to be callable
	 * Add this to prevent the user from manually calling the functions
    */
	UFUNCTION(NotBlueprintCallable)
	void ExampleNotCallable()
	{

	}

    // BlueprintEvent allows this function to be overridden in blueprint.
    //   Note that the function will not be callable from blueprint, only overridable,
    //   unless you also specify BlueprintCallable in the specifiers.
    UFUNCTION(BlueprintEvent)
    void BlueprintEventFunction()
    {
    }

    // You can also categorize your functions, same as BP
    UFUNCTION(Category = "Really Cool Category")
    void CategorizedFunction()
    {
    }

    // You can chain specifiers together in a single function, using a comma to separate specifiers
    UFUNCTION(BlueprintPure, BlueprintEvent, Category = "Hi Mum")
    int ReallySpecifiedFunction()
    {
        return 1337;
    }

    /*  BlueprintOverride overrides the C++ function.
    *   Includes functions such as Tick, BeginPlay, ConstructionScript etc
    */
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
    }

	/* This adds a button to the "Details" panel of the object
	 * Use this to precalculate stuff in the editor and store it in UPROPERTY
	 * To optimize loadingtimes for example.
	 * This function is not included in the final version of the game
    */
	UFUNCTION(CallInEditor)
	void ExampleCallInEditorFunction()
	{

	}

};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleFunctionSpecifiersTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleFunctionSpecifiersTest, "Angelscript.TestModule.ScriptExamples.FunctionSpecifiers", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleFunctionSpecifiersTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GFunctionSpecifiersExample);
}

#endif
