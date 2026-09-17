/**
 * @version v1
 * @summary DestroyComponent on a runtime script component, which must leave it both destroying and unregistered. C++ spawns the actor, calls DestroySelf and then inspects the probe. The observers cover the local-construct default.
 * @topic World
 */
/**
 * @version root
 * @summary DestroyComponent on a runtime script component, which must leave it both destroying and unregistered. C++ spawns the actor, calls DestroySelf and then inspects the probe. The observers cover the local-construct default.
 * @topic Baseline
 */
UCLASS()
class UTestComponentLifecycleDestroyProbe : UActorComponent
{
	/**
	 * Destroy this component and report that the call completed.
	 *
	 * @Kind Action
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int DestroySelf()
	{
		DestroyComponent();
		return 1;
	}
}

UCLASS()
class ATestComponentLifecycleDestroy : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleDestroyProbe Probe;

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultProbeNull()
	{
		return Probe == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null probe.
	 *
	 * @Kind Observe
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs this actor plus a second actor
	 * @Return true when both probes are null
	 * @Param Second the other actor, also expected to hold a null probe
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestComponentLifecycleDestroy Second)
	{
		if (Second is null)
		{
			throw("DestroyComponentUnregistersRuntimeComponent setup: required Second is null");
		}
		if (Probe != nullptr)
		{
			return false;
		}
		return Second.Probe == nullptr;
	}
}
/** @end */
