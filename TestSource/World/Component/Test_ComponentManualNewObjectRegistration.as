// Theme: World.Component. WorldStory: NewObject script component, tags,
// Activate/Deactivate, AddValue.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentManualNewObjectRegistration
// sha256=d3befe561382d0d95da7bd9bfa5cf02693e2b0e48f52f7896a09b176d832a6c6; lines 2412-2478.
// Oracle: NewObjectCreated true, ManualComp unregistered before native
// register, Owner/World matched, TaggedAfterRegister true, Active then
// inactive, CustomMethodValue=42 (29+13). Extra: local construct ManualComp
// null, flags false, CustomMethodValue 0. FixtureIsolated.

UCLASS()
class UCoverageManualNewObjectComponent : UActorComponent
{
	UPROPERTY()
	int BaseValue = 29;

	UFUNCTION()
	int AddValue(int ExtraValue)
	{
		return BaseValue + ExtraValue;
	}
}

UCLASS()
class ACoverageComponentManualNewObjectActor : AActor
{
	UPROPERTY()
	UCoverageManualNewObjectComponent ManualComp;

	UPROPERTY()
	bool NewObjectCreated = false;

	UPROPERTY()
	bool OwnerBeforeRegisterMatched = false;

	UPROPERTY()
	bool WorldBeforeRegisterMatched = false;

	UPROPERTY()
	bool TaggedAfterRegister = false;

	UPROPERTY()
	bool ActiveAfterActivate = false;

	UPROPERTY()
	bool InactiveAfterDeactivate = false;

	UPROPERTY()
	int CustomMethodValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ManualComp = Cast<UCoverageManualNewObjectComponent>(NewObject(this, UCoverageManualNewObjectComponent::StaticClass(), n"ManualNewObjectComp", true));
		NewObjectCreated = ManualComp != nullptr;
		if (ManualComp == nullptr)
		{
			return;
		}

		OwnerBeforeRegisterMatched = ManualComp.GetOwner() == this;
		WorldBeforeRegisterMatched = ManualComp.GetWorld() == GetWorld();
		ManualComp.ComponentTags.Add(n"ManualNewObject");

		TaggedAfterRegister = ManualComp.ComponentHasTag(n"ManualNewObject");

		ManualComp.Activate(true);
		ActiveAfterActivate = ManualComp.IsActive();

		ManualComp.Deactivate();
		InactiveAfterDeactivate = !ManualComp.IsActive();

		CustomMethodValue = ManualComp.AddValue(13);
	}
}

bool Observe_ManualNewObject_DefaultNull(ACoverageComponentManualNewObjectActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentManualNewObjectRegistration setup: required Actor is null");
	}
	return Actor.ManualComp == nullptr
		&& !Actor.NewObjectCreated
		&& !Actor.OwnerBeforeRegisterMatched
		&& !Actor.WorldBeforeRegisterMatched
		&& !Actor.TaggedAfterRegister
		&& !Actor.ActiveAfterActivate
		&& !Actor.InactiveAfterDeactivate
		&& Actor.CustomMethodValue == 0;
}

int Observe_ManualNewObject_AddValue_ZeroBoundary(UCoverageManualNewObjectComponent Comp)
{
	if (Comp is null)
	{
		throw("Test_ComponentManualNewObjectRegistration setup: required Comp is null");
	}
	return Comp.AddValue(0);
}
