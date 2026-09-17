/**
 * @version v1
 * @summary A component created at runtime with Create, then activated and deactivated. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the flags by path, so this is a value oracle. The.
 * @topic World
 */
/**
 * @version root
 * @summary A component created at runtime with Create, then activated and deactivated. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the flags by path, so this is a value oracle. The.
 * @topic Baseline
 */
UCLASS()
class UCoverageRuntimeLogicComponent : UActorComponent
{
	UPROPERTY()
	int Value = 17;
}

UCLASS()
class ACoverageComponentRegistrationActivationActor : AActor
{
	UPROPERTY()
	UCoverageRuntimeLogicComponent RuntimeComp;

	UPROPERTY()
	bool RegisteredAfterCreate = false;

	UPROPERTY()
	bool ActiveAfterActivate = false;

	UPROPERTY()
	bool InactiveAfterDeactivate = false;

	UPROPERTY()
	bool OwnerMatched = false;

	UPROPERTY()
	bool WorldMatched = false;

	/**
	 * WorldStory: create the component at runtime, walk activation, then confirm
	 * the owner and world it landed in.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs none
	 * @Return all five flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeComp = UCoverageRuntimeLogicComponent::Create(this, n"RuntimeComp");
		RegisteredAfterCreate = RuntimeComp != nullptr;

		RuntimeComp.Activate(true);
		ActiveAfterActivate = RuntimeComp.IsActive();

		RuntimeComp.Deactivate();
		InactiveAfterDeactivate = !RuntimeComp.IsActive();

		OwnerMatched = RuntimeComp.GetOwner() == this;
		WorldMatched = RuntimeComp.GetWorld() == GetWorld();
	}

	/**
	 * Observe that a locally constructed actor has no component and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when RuntimeComp is null and all flags are clear
	 * @Boundary null runtime component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RuntimeComp != nullptr)
		{
			return false;
		}
		if (RegisteredAfterCreate)
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
		if (OwnerMatched)
		{
			return false;
		}
		return !WorldMatched;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other stays null and unflagged
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentRegistrationActivationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentRegistrationAndActivation setup: required Second is null");
		}
		RegisteredAfterCreate = true;

		if (!RegisteredAfterCreate)
		{
			return false;
		}
		if (Second.RegisteredAfterCreate)
		{
			return false;
		}
		return Second.RuntimeComp == nullptr;
	}
}
/** @end */
