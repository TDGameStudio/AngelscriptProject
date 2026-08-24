// Theme: Definitions.UProperty. WorldStory: DefaultComponent/ShowOnActor/Instanced flags plus BeginPlay assignment.
// C++: VisibleChildValid true; InlineObjectAssigned true (Value 19); VisibleChild CPF_Edit/BlueprintVisible/ReadOnly.
// Extra: null VisibleChild leaves VisibleChildValid false; missing NewObject leaves InlineObjectAssigned false.
// FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VisibleChildValid = VisibleChild != nullptr;
		InlineObject = Cast<UCoverageInstancedLogicObject>(NewObject(this, UCoverageInstancedLogicObject::StaticClass()));
		InlineObjectAssigned = InlineObject != nullptr && InlineObject.Value == 19;
	}
}

bool Observe_NullVisibleChildIsInvalid()
{
	USceneComponent VisibleChild;
	return VisibleChild == nullptr;
}

bool Observe_NullInlineObjectIsUnassigned()
{
	UCoverageInstancedLogicObject InlineObject;
	return InlineObject == nullptr;
}
