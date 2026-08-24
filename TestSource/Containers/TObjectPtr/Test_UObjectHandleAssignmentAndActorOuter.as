// Theme: Containers.TObjectPtr. WorldStory: UObject null assign, identity, actor Outer.
// C++ VerifyByPath: NullAssignmentWorked, AssignmentEqualityWorked, ReassignmentWorked,
// ActorOuterWorked true; OuterOwnedObject Outer is this. Extra: OuterOwnedObject default null.
// FixtureIsolated.

UCLASS()
class ACoverageHandleUObjectAssignmentActorOuter : AActor
{
	UPROPERTY()
	UObject OuterOwnedObject;

	UPROPERTY()
	bool NullAssignmentWorked = false;

	UPROPERTY()
	bool AssignmentEqualityWorked = false;

	UPROPERTY()
	bool ReassignmentWorked = false;

	UPROPERTY()
	bool ActorOuterWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject ObjectA = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleObjectA");
		UObject ObjectB = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleObjectB");

		UObject GenericObject = nullptr;
		NullAssignmentWorked = GenericObject == nullptr;

		GenericObject = ObjectA;
		AssignmentEqualityWorked = GenericObject == ObjectA && GenericObject != ObjectB;

		OuterOwnedObject = ObjectB;
		ActorOuterWorked = OuterOwnedObject != nullptr && OuterOwnedObject.GetOuter() == this;

		GenericObject = OuterOwnedObject;
		ReassignmentWorked = GenericObject == ObjectB && GenericObject != ObjectA;
	}
}
