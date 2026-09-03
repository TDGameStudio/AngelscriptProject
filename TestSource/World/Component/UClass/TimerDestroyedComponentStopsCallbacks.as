/**
 * A component that owns a timer, destroyed to confirm its callbacks stop. C++
 * verifies the active flag before the destroy and the destroyed flag afterwards.
 * The observers cover the declared defaults and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.TimerDestroyedComponentStopsCallbacks
 * @Harness UClass
 * @Tag World.Component.TimerDestroyedComponentStopsCallbacks
 * @Provenance Theme: World.Component. WorldStory: destroy a component that owns a timer.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDestroyedComponentStopsCallbacks
 * @Provenance sha256=08b396d21470e9b1eb914ca7789ece21623e37b0a9262b2f65b227c988d32ed3; lines 2563-2624.
 * @Provenance Oracle bComponentTimerActiveBeforeDestroy true; after DestroyTimerComponent
 * @Provenance bComponentDestroyed true, ObservedCallbackCount 0.
 * @Provenance Extra: local construct flags false, ObservedCallbackCount -1 (declared),
 * @Provenance DestroyableComponent null. FixtureIsolated.
 */

UCLASS()
class UCoverageTimerDestroyableComponent : UActorComponent
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyedComponentHandle;

	/**
	 * Count each timer callback the component receives.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return CallbackCount incremented once per callback
	 */
	UFUNCTION()
	void CallbackAfterDestroy()
	{
		CallbackCount++;
	}

	/**
	 * Start the repeating timer and record whether it went active.
	 *
	 * @Kind Action
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return bTimerActiveBeforeDestroy set from the timer's active state
	 */
	UFUNCTION()
	void ConfigureTimer()
	{
		DestroyedComponentHandle = System::SetTimer(this, n"CallbackAfterDestroy", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyedComponentHandle);
	}
}

UCLASS()
class ACoverageTimerDestroyedComponentOwner : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTimerDestroyableComponent DestroyableComponent;

	UPROPERTY()
	bool bComponentTimerActiveBeforeDestroy = false;

	UPROPERTY()
	bool bComponentDestroyed = false;

	UPROPERTY()
	int ObservedCallbackCount = -1;

	/**
	 * WorldStory: BeginPlay configures the component timer and records that it was
	 * active.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs a default-attached timer component
	 * @Return bComponentTimerActiveBeforeDestroy true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyableComponent.ConfigureTimer();
		bComponentTimerActiveBeforeDestroy = DestroyableComponent.bTimerActiveBeforeDestroy;
	}

	/**
	 * Destroy the component that owns the timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return bComponentDestroyed set from the component's destroying state
	 */
	UFUNCTION()
	void DestroyTimerComponent()
	{
		DestroyableComponent.DestroyComponent();
		bComponentDestroyed = DestroyableComponent.IsBeingDestroyed();
	}

	/**
	 * Copy the component's callback count onto this actor.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return ObservedCallbackCount copied off the component
	 */
	UFUNCTION()
	void SnapshotDestroyedComponent()
	{
		ObservedCallbackCount = DestroyableComponent.CallbackCount;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is -1 and the component is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bComponentTimerActiveBeforeDestroy)
		{
			return false;
		}
		if (bComponentDestroyed)
		{
			return false;
		}
		if (ObservedCallbackCount != -1)
		{
			return false;
		}
		return DestroyableComponent == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the destroyed state and the other keeps its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerDestroyedComponentOwner Second)
	{
		if (Second is null)
		{
			throw("TimerDestroyedComponentStopsCallbacks setup: required Second is null");
		}
		bComponentDestroyed = true;
		ObservedCallbackCount = 0;

		if (!bComponentDestroyed)
		{
			return false;
		}
		if (ObservedCallbackCount != 0)
		{
			return false;
		}
		if (Second.bComponentDestroyed)
		{
			return false;
		}
		return Second.ObservedCallbackCount == -1;
	}
}
