/**
 * @version v1
 * @summary A component whose EndPlay records the destruction state, driven by an explicit DestroyProbeComponent action on the owning actor. C++ verifies the two flags and the EndPlay count. The observers cover the local-construct.
 * @topic World
 */
/**
 * @version root
 * @summary A component whose EndPlay records the destruction state, driven by an explicit DestroyProbeComponent action on the owning actor. C++ verifies the two flags and the EndPlay count. The observers cover the local-construct.
 * @topic Baseline
 */
UCLASS()
class UCoverageDestroyStateComponent : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	bool DestroyingDuringEndPlay = false;

	/**
	 * WorldStory: EndPlay records that the component is already being destroyed.
	 *
	 * @Kind WorldStory
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCount incremented and DestroyingDuringEndPlay set from IsBeingDestroyed
	 * @Param EndPlayReason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount++;
		DestroyingDuringEndPlay = IsBeingDestroyed();
	}
}

UCLASS()
class ACoverageComponentDestructionStateActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDestroyStateComponent DestroyProbe;

	UPROPERTY()
	bool DestroyCallCompleted = false;

	UPROPERTY()
	bool BeingDestroyedAfterCall = false;

	/**
	 * Destroy the probe component and record the state it entered.
	 *
	 * @Kind Action
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs none
	 * @Return DestroyCallCompleted and BeingDestroyedAfterCall set; both stay false when the probe is null
	 */
	UFUNCTION()
	void DestroyProbeComponent()
	{
		if (DestroyProbe == nullptr)
		{
			return;
		}

		DestroyProbe.DestroyComponent();
		DestroyCallCompleted = true;
		BeingDestroyedAfterCall = DestroyProbe.IsBeingDestroyed();
	}

	/**
	 * Observe that a locally constructed actor has not destroyed anything.
	 *
	 * @Kind Observe
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs an actor that has not run the destroy action
	 * @Return true when both flags are clear and DestroyProbe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (DestroyCallCompleted)
		{
			return false;
		}
		if (BeingDestroyedAfterCall)
		{
			return false;
		}
		return DestroyProbe == nullptr;
	}

	/**
	 * Observe that the destroy action is a no-op without a probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs an actor whose probe component is null
	 * @Return true when both flags stay clear after the call
	 * @Boundary null probe
	 */
	UFUNCTION()
	bool NullProbeIsNoop()
	{
		DestroyProbeComponent();

		if (DestroyCallCompleted)
		{
			return false;
		}
		return !BeingDestroyedAfterCall;
	}
}
/** @end */
