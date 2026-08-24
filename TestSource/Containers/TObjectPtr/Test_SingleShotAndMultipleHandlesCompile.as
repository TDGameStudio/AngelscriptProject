// Theme: Containers.TObjectPtr. WorldStory: FTimerHandle single-shot and looping Set/Clear.
// CSV NegativeDiagnostic is wrong; C++ compiles and VerifyByPath all four flags true.
// Extra: flags default false until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTimerMultipleHandlesActor : AActor
{
	UPROPERTY()
	bool bSingleShotInitiallyActive = false;

	UPROPERTY()
	bool bLoopInitiallyActive = false;

	UPROPERTY()
	bool bSingleShotClearObserved = false;

	UPROPERTY()
	bool bLoopClearObserved = false;

	FTimerHandle SingleShotHandle;
	FTimerHandle LoopingHandle;

	UFUNCTION()
	void SingleShotCallback()
	{
	}

	UFUNCTION()
	void LoopCallback()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SingleShotHandle = System::SetTimer(this, n"SingleShotCallback", 0.25f, false);
		LoopingHandle = System::SetTimer(this, n"LoopCallback", 0.5f, true);

		bSingleShotInitiallyActive = !System::IsTimerPausedHandle(SingleShotHandle);
		bLoopInitiallyActive = !System::IsTimerPausedHandle(LoopingHandle);

		System::ClearAndInvalidateTimerHandle(SingleShotHandle);
		System::ClearAndInvalidateTimerHandle(LoopingHandle);

		bSingleShotClearObserved = !System::IsTimerPausedHandle(SingleShotHandle);
		bLoopClearObserved = !System::IsTimerPausedHandle(LoopingHandle);
	}
}
