// Theme: World.Component. CSV NegativeDiagnostic; C++ compiles then
// VerifyByPath after pause/snapshot. Value/lifecycle oracle.
// C++: AngelscriptCoverageTimerTests.cpp::TimerComponentCallbacksRunOnOwnerWorld
// sha256=514d79b6ce799ff6a4b676930fcd7b751cd3797404f4ca5a3f77584e4cb56556; lines 2314-2403.
// Oracle bComponentSetupComplete true; after pause snapshot
// bComponentPausedStoppedCallbacks true, ObservedComponentCallCount 0.
// Extra: local construct flags false, ObservedComponentCallCount 0,
// TimerComponent null. FixtureIsolated.

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

	UFUNCTION()
	void ComponentCallback()
	{
		ComponentCallCount++;
	}

	UFUNCTION()
	void ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 0.1f, true);
		bActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
	}

	UFUNCTION()
	void PauseComponentTimer()
	{
		System::PauseTimerHandle(ComponentHandle);
	}

	UFUNCTION()
	void MarkPausedResult()
	{
		bPausedStoppedCallbacks = System::IsTimerPausedHandle(ComponentHandle);
	}

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TimerComponent.ConfigureComponentTimer();
		bComponentSetupComplete = TimerComponent.bActiveAfterSetup;
	}

	UFUNCTION()
	void PauseComponentTimerFromOwner()
	{
		TimerComponent.PauseComponentTimer();
	}

	UFUNCTION()
	void SnapshotComponentTimerState()
	{
		TimerComponent.MarkPausedResult();
		bComponentPausedStoppedCallbacks = TimerComponent.bPausedStoppedCallbacks;
		ObservedComponentCallCount = TimerComponent.ComponentCallCount;
	}

	UFUNCTION()
	void ClearComponentTimerFromOwner()
	{
		TimerComponent.ClearComponentTimer();
	}
}

bool Observe_TimerComponentCallbacks_DefaultEmpty(ACoverageTimerComponentOwnerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerComponentCallbacksRunOnOwnerWorld setup: required Actor is null");
	}
	return !Actor.bComponentSetupComplete
		&& !Actor.bComponentPausedStoppedCallbacks
		&& Actor.ObservedComponentCallCount == 0
		&& Actor.TimerComponent == nullptr;
}

bool Observe_TimerComponentCallbacks_CopyIndependence(ACoverageTimerComponentOwnerActor First, ACoverageTimerComponentOwnerActor Second)
{
	if (First is null)
	{
		throw("Test_TimerComponentCallbacksRunOnOwnerWorld setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TimerComponentCallbacksRunOnOwnerWorld setup: required Second is null");
	}
	First.bComponentSetupComplete = true;
	First.ObservedComponentCallCount = 3;
	return First.bComponentSetupComplete
		&& First.ObservedComponentCallCount == 3
		&& !Second.bComponentSetupComplete
		&& Second.ObservedComponentCallCount == 0;
}
