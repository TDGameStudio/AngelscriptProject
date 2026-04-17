#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleWidgetUmgTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GWidgetUmgExample = {
		TEXT("Example_Widget_UMG.as"),
		TEXT(R"ANGELSCRIPT(
/**
 * This in an example for a baseclass for an UMG widget.
 *  You can create a widget blueprint and set this class as the parent class.
 *  Then you can create certain functionality in script while designing the UI
 *  in the widget blueprint.
 */
class UExampleWidget_UnitTest : UUserWidget
{
	// BindWidget automatically assigns this property to the widget named MainText in the widget blueprint.
	// If you don't have a widget called MainText in the widget blueprint you will get an error.
	UPROPERTY(BindWidget)
	UTextBlock MainText;

    float TimePassed = 0.0;

    UFUNCTION(BlueprintOverride)
    void Construct()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(FGeometry MyGeometry, float DeltaTime)
    {
        TimePassed += DeltaTime;
        MainText.Text = FText::FromString("Time Passed: "+TimePassed);
    }
};

/**
 * This is a global function that can add a widget of a specific class to a player's HUD.
 *  This can be called for example from level blueprint to specify which widget blueprint to show.
 */
UFUNCTION(Category = "Examples | Player HUD Widget")
void Example_AddExampleWidgetToHUD(APlayerController OwningPlayer, TSubclassOf<UExampleWidget_UnitTest> WidgetClass)
{
    UUserWidget UserWidget = WidgetBlueprint::CreateWidget(WidgetClass, OwningPlayer);
    UserWidget.AddToViewport();
})ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleWidgetUmgTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleWidgetUmgTest, "Angelscript.TestModule.ScriptExamples.WidgetUMG", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleWidgetUmgTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GWidgetUmgExample);
}

#endif
