#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExamplePropertySpecifiersTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GPropertySpecifiersExample = {
		TEXT("Example_PropertySpecifiers.as"),
		TEXT(R"ANGELSCRIPT(class AExamplePropertySpecifierActor_UnitTest : AActor
{
    /* When declaring properties, Property Specifiers can be added to the declaration to control how
     * the property behaves with various aspects of the Engine and Editor.
     */

    /* Adding UPROPERTY allows the property to be visible to Unreal.
     * Properties using UPROPERTY are editable by default.
     */
    UPROPERTY()
    float UnrealFloatProperty;

    /* Properties set to DefaultComponent will be created as components on the class automatically.
	 * Without it, it would just be a reference to any component.
     */
    UPROPERTY()
    USceneComponent SceneComponent;

    // Setting RootComponent makes this component the default root for this class.
    UPROPERTY()
    USceneComponent RootSceneComponent;

    // Attach will attach the component to the specified component.
    UPROPERTY()
    UBillboardComponent DinoComponent;

	// AttachSocket will attach to the specified socket, if valid
	UPROPERTY()
    USceneComponent FaceAttachedComponent;

    /* ShowOnActor makes the component's properties visible when you select the actor,
     * not just when you select the component.
	 * 'ShowOnlyInnerProperties' will expand the properties to outer layer
     */
    UPROPERTY(meta = (ShowOnlyInnerProperties))
    USplineComponent SplineComponent;

    /* Category allows you to specifiy a category for the property
     * Using | allows you to add sub categories
     */
    UPROPERTY(Category = "Main Category|Sub Category")
    float CategorizedFloat = 1337.0;

    // NotEditable hides the property from the details panel
    UPROPERTY(NotEditable)
    bool bCoolBool;

    /* EditConst makes the property uneditable
     * (Still visible in the details panel, but uneditable)
     */
    UPROPERTY(EditConst)
    bool bReallyCoolBool;

    // BlueprintReadOnly: Can Get, but cannot Set in blueprints.
    UPROPERTY(BlueprintReadOnly)
    bool bReadOnlyBool;

    // The meta tag MakeEditWidget turns the FVector or FTransform into a 3D edit widget
    UPROPERTY(meta = (MakeEditWidget))
    FVector WidgetEditableVector;


    /* Using the meta EditCondition and InlineEditConditionToggle you can create a float assigned to a bool.
     * While false, the float is unable to be edited.
     */
    UPROPERTY(meta = (EditCondition = "bEditConditionBool"))
	float ConditionalFloat;
	UPROPERTY(meta = (InlineEditConditionToggle))
	bool bEditConditionBool = true;

	// This will clamp the values in the editor window
	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1.0", UIMin = "0.0", UIMax = "1.0"))
	float ExampleClampedValue;

};)ANGELSCRIPT"),
		TEXT("Example_Enum.as"),
		AngelscriptScriptExamples::GetScriptExampleEnumSource().ScriptText,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExamplePropertySpecifiersTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExamplePropertySpecifiersTest, "Angelscript.TestModule.ScriptExamples.PropertySpecifiers", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExamplePropertySpecifiersTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GPropertySpecifiersExample);
}

#endif
