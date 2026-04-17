#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleConstructionScriptTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GConstructionScriptExample = {
		TEXT("Example_ConstructionScript.as"),
		TEXT(R"ANGELSCRIPT(/*
 * This is an example on how to use construction scripts
 * for angelscript classes. This class creates a root component
 * for itself using a construction script instead of a DefaultComponent,
 * and calculates a derived property.
 */
class AExampleConstructionScript_UnitTest : AActor
{
	UPROPERTY(NotVisible)
	UBillboardComponent Billboard;

	UPROPERTY(Category = "Calculation")
	int ValueA = 3;

	UPROPERTY(Category = "Calculation")
	int ValueB = 3;

	/* This will be set by the construction script to the value of (ValueA * ValueB) */
	UPROPERTY(BlueprintReadOnly, NotEditable, Category = "Calculation")
	int Product;

	/* The overridden construction script will run when needed. */
	UFUNCTION()
	void ConstructionScript()
	{
		// Create a component dynamically from construction script
		Billboard = UBillboardComponent::Create(this, n"Billboard");

		// Set the derived property
		Product = ValueA * ValueB;
	}
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleConstructionScriptTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleConstructionScriptTest, "Angelscript.TestModule.ScriptExamples.ConstructionScript", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleConstructionScriptTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GConstructionScriptExample);
}

#endif
