/**
 * @version v1
 * @summary A timer owned by a component, driven and snapshotted from the owning actor. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and verifies the flags by path after a pause and snapshot, so this is a value.
 * @topic World
 */
/**
 * @version root
 * @summary A timer owned by a component, driven and snapshotted from the owning actor. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and verifies the flags by path after a pause and snapshot, so this is a value.
 * @topic Baseline
 */
UCLASS()
class UCoverageTimerRuntimeComponent : UActorComponent
{
	UPROPERTY()
	int ComponentCallCount = 0;

	UPROPERTY()
	bool bActiveAfterSetup = false;

	UPROPERTY()
	bool bPausedStoppedCallbacks = false;

	FTimerHandle ComponentHandle;

	/**
	 * Count each timer callback the component receives.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return ComponentCallCount incremented once per callback
	 */
	UFUNCTION()
	void ComponentCallback()
	{
		ComponentCallCount++;
	}

	/**
	 * Start the repeating component timer and record whether it went active.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bActiveAfterSetup set from the timer's active state
	 */
	UFUNCTION()
	void ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 0.1f, true);
		bActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
	}

	/**
	 * Pause the component timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the timer left paused
	 */
	UFUNCTION()
	void PauseComponentTimer()
	{
		System::PauseTimerHandle(ComponentHandle);
	}

	/**
	 * Record whether the timer is currently paused.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bPausedStoppedCallbacks set from the timer's paused state
	 */
	UFUNCTION()
	void MarkPausedResult()
	{
		bPausedStoppedCallbacks = System::IsTimerPausedHandle(ComponentHandle);
	}

	/**
	 * Clear the component timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the timer handle cleared and invalidated
	 */
	UFUNCTION()
	void ClearComponentTimer()
	{
		System::ClearAndInvalidateTimerHandle(ComponentHandle);
	}
}

UCLASS()
class ACoverageTimerComponentOwnerActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTimerRuntimeComponent TimerComponent;

	UPROPERTY()
	bool bComponentSetupComplete = false;

	UPROPERTY()
	bool bComponentPausedStoppedCallbacks = false;

	UPROPERTY()
	int ObservedComponentCallCount = 0;

	/**
	 * WorldStory: BeginPlay starts the component timer and records that setup
	 * completed.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs a default-attached timer component
	 * @Return bComponentSetupComplete true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TimerComponent.ConfigureComponentTimer();
		bComponentSetupComplete = TimerComponent.bActiveAfterSetup;
	}

	/**
	 * Pause the component timer from the owning actor.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the component timer left paused
	 */
	UFUNCTION()
	void PauseComponentTimerFromOwner()
	{
		TimerComponent.PauseComponentTimer();
	}

	/**
	 * Copy the component's timer state and callback count onto this actor.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bComponentPausedStoppedCallbacks and ObservedComponentCallCount copied off the component
	 */
	UFUNCTION()
	void SnapshotComponentTimerState()
	{
		TimerComponent.MarkPausedResult();
		bComponentPausedStoppedCallbacks = TimerComponent.bPausedStoppedCallbacks;
		ObservedComponentCallCount = TimerComponent.ComponentCallCount;
	}

	/**
	 * Clear the component timer from the owning actor.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the component timer handle cleared
	 */
	UFUNCTION()
	void ClearComponentTimerFromOwner()
	{
		TimerComponent.ClearComponentTimer();
	}

	/**
	 * Observe that a locally constructed actor has no flags, no count and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is 0 and TimerComponent is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bComponentSetupComplete)
		{
			return false;
		}
		if (bComponentPausedStoppedCallbacks)
		{
			return false;
		}
		if (ObservedComponentCallCount != 0)
		{
			return false;
		}
		return TimerComponent == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the snapshotted state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerComponentOwnerActor Second)
	{
		if (Second is null)
		{
			throw("TimerComponentCallbacksRunOnOwnerWorld setup: required Second is null");
		}
		bComponentSetupComplete = true;
		ObservedComponentCallCount = 3;

		if (!bComponentSetupComplete)
		{
			return false;
		}
		if (ObservedComponentCallCount != 3)
		{
			return false;
		}
		if (Second.bComponentSetupComplete)
		{
			return false;
		}
		return Second.ObservedComponentCallCount == 0;
	}
}
/** @end */
