/**
 * DefaultComponent/ShowOnActor/Instanced flags plus BeginPlay assignment. C++
 * verifies named properties by path, so those UPROPERTY names are kept. The
 * observers cover a null VisibleChild and a null InlineObject.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ComponentPropertySpecifiers
 * @Harness UClass
 * @Tag Definitions.UProperty.ComponentPropertySpecifiers
 * @Provenance Theme: Definitions.UProperty. WorldStory: DefaultComponent/ShowOnActor/Instanced flags plus BeginPlay assignment.
 * @Provenance C++: VisibleChildValid true; InlineObjectAssigned true (Value 19); VisibleChild CPF_Edit/BlueprintVisible/ReadOnly.
 * @Provenance Extra: null VisibleChild leaves VisibleChildValid false; missing NewObject leaves InlineObjectAssigned false.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UCoverageInstancedLogicObject : UObject
{
	UPROPERTY()
	int Value = 19;
}

UCLASS()
class ACoverageComponentPropertySpecifierActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, ShowOnActor, EditAnywhere, BlueprintReadOnly)
	USceneComponent VisibleChild;

	UPROPERTY(Instanced)
	UCoverageInstancedLogicObject InlineObject;

	UPROPERTY()
	bool VisibleChildValid = false;

	UPROPERTY()
	bool InlineObjectAssigned = false;

	/**
	 * WorldStory: mark VisibleChild valid and assign an instanced object of Value 19.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.ComponentPropertySpecifiers
	 * @Inputs none
	 * @Return VisibleChildValid true; InlineObjectAssigned true when Value is 19
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VisibleChildValid = VisibleChild != nullptr;
		InlineObject = Cast<UCoverageInstancedLogicObject>(NewObject(this, UCoverageInstancedLogicObject::StaticClass()));
		InlineObjectAssigned = InlineObject != nullptr && InlineObject.Value == 19;
	}

	/**
	 * Observe that a null VisibleChild is invalid.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ComponentPropertySpecifiers
	 * @Inputs an unset USceneComponent
	 * @Return true when the component is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool NullVisibleChildIsInvalid()
	{
		USceneComponent VisibleChild;
		return VisibleChild == nullptr;
	}

	/**
	 * Observe that a null InlineObject is unassigned.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ComponentPropertySpecifiers
	 * @Inputs an unset UCoverageInstancedLogicObject
	 * @Return true when the object is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool NullInlineObjectIsUnassigned()
	{
		UCoverageInstancedLogicObject InlineObject;
		return InlineObject == nullptr;
	}
}
