/**
 * @version v1
 * @summary A component whose BeginPlay walks IsActive through Deactivate and Activate. C++ verifies the three outcome flags by path. The observers cover the local-construct defaults and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary A component whose BeginPlay walks IsActive through Deactivate and Activate. C++ verifies the three outcome flags by path. The observers cover the local-construct defaults and copy independence.
 * @topic Baseline
 */
UCLASS()
class UCoverageActivationComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentActivationActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageActivationComponent TestComp;

	UPROPERTY()
	bool InitiallyActive = false;

	UPROPERTY()
	bool AfterDeactivate = true;

	UPROPERTY()
	bool AfterReactivate = false;

	/**
	 * WorldStory: BeginPlay records the active state, deactivates, then reactivates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ComponentActivation
	 * @Inputs a default-attached UCoverageActivationComponent
	 * @Return InitiallyActive false, AfterDeactivate false, AfterReactivate true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyActive = TestComp.IsActive();

		TestComp.Deactivate();
		AfterDeactivate = TestComp.IsActive();

		TestComp.Activate(true);
		AfterReactivate = TestComp.IsActive();
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.ComponentActivation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the declared defaults hold and TestComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitiallyActive)
		{
			return false;
		}
		if (!AfterDeactivate)
		{
			return false;
		}
		if (AfterReactivate)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ComponentActivation
	 * @Inputs this actor plus a second actor
	 * @Return true when this is reactivated and the other keeps its defaults
	 * @Param Second the other actor, expected to keep the declared defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentActivationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentActivation setup: required Second is null");
		}
		AfterReactivate = true;
		AfterDeactivate = false;

		if (!AfterReactivate)
		{
			return false;
		}
		if (AfterDeactivate)
		{
			return false;
		}
		if (Second.AfterReactivate)
		{
			return false;
		}
		return Second.AfterDeactivate;
	}
}
/** @end */
