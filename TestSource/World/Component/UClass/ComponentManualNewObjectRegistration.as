/**
 * A component built with NewObject rather than declared as a default component,
 * then tagged, activated, deactivated and called through a custom method. C++
 * verifies every flag. The observers cover the local-construct default and the
 * zero boundary of the custom method.
 *
 * @Theme World.Component
 * @Subject Component.ManualNewObjectRegistration
 * @Harness UClass
 * @Tag World.Component.ComponentManualNewObjectRegistration
 * @Provenance Theme: World.Component. WorldStory: NewObject script component, tags,
 * @Provenance Activate/Deactivate, AddValue.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentManualNewObjectRegistration
 * @Provenance sha256=d3befe561382d0d95da7bd9bfa5cf02693e2b0e48f52f7896a09b176d832a6c6; lines 2412-2478.
 * @Provenance Oracle: NewObjectCreated true, ManualComp unregistered before native
 * @Provenance register, Owner/World matched, TaggedAfterRegister true, Active then
 * @Provenance inactive, CustomMethodValue=42 (29+13). Extra: local construct ManualComp
 * @Provenance null, flags false, CustomMethodValue 0. FixtureIsolated.
 */

UCLASS()
class UCoverageManualNewObjectComponent : UActorComponent
{
	UPROPERTY()
	int BaseValue = 29;

	/**
	 * Add an extra value onto the base value.
	 *
	 * @Kind Action
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs an extra value to add
	 * @Return BaseValue + ExtraValue
	 * @Param ExtraValue the amount to add
	 */
	UFUNCTION()
	int AddValue(int ExtraValue)
	{
		return BaseValue + ExtraValue;
	}

	/**
	 * Observe that adding zero returns the base value unchanged.
	 *
	 * @Kind Observe
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs a component whose BaseValue is 29
	 * @Return AddValue(0)
	 * @Boundary zero extra value
	 */
	UFUNCTION()
	int AddValueZeroBoundary()
	{
		return AddValue(0);
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

	/**
	 * WorldStory: build the component with NewObject, then walk tags, activation
	 * and the custom method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs none
	 * @Return all flags true and CustomMethodValue == 42; all stay false when NewObject fails
	 */
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

	/**
	 * Observe that a locally constructed actor has no component and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when ManualComp is null, all flags are clear and the value is 0
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (ManualComp != nullptr)
		{
			return false;
		}
		if (NewObjectCreated)
		{
			return false;
		}
		if (OwnerBeforeRegisterMatched)
		{
			return false;
		}
		if (WorldBeforeRegisterMatched)
		{
			return false;
		}
		if (TaggedAfterRegister)
		{
			return false;
		}
		if (ActiveAfterActivate)
		{
			return false;
		}
		if (InactiveAfterDeactivate)
		{
			return false;
		}
		return CustomMethodValue == 0;
	}
}
