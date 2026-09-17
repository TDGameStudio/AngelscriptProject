/**
 * @version v1
 * @summary Script subsystem Initialize/Deinitialize/OnWorldBeginPlay. C++ looks up BP_Initialize / BP_Deinitialize / BP_OnWorldBeginPlay UFunctions on the generated classes.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Script subsystem Initialize/Deinitialize/OnWorldBeginPlay. C++ looks up BP_Initialize / BP_Deinitialize / BP_OnWorldBeginPlay UFunctions on the generated classes.
 * @topic Baseline
 */
UCLASS()
class UCoverageLifecycleWorldSubsystem : UScriptWorldSubsystem
{
	UPROPERTY()
	int InitializeCount = 0;

	UPROPERTY()
	int DeinitializeCount = 0;

	UPROPERTY()
	int WorldBeginPlayCount = 0;

	/**
	 * WorldStory: Initialize increments InitializeCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return InitializeCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		InitializeCount++;
	}

	/**
	 * WorldStory: Deinitialize increments DeinitializeCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return DeinitializeCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
		DeinitializeCount++;
	}

	/**
	 * WorldStory: OnWorldBeginPlay increments WorldBeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return WorldBeginPlayCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
		WorldBeginPlayCount++;
	}

	/**
	 * Observe that an unset world-subsystem handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs an unset UCoverageLifecycleWorldSubsystem handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageLifecycleWorldSubsystem Sub;
		return Sub == nullptr;
	}

	/**
	 * Observe subsystem counters at defaults.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs a freshly constructed world subsystem
	 * @Return InitializeCount + DeinitializeCount + WorldBeginPlayCount
	 * @Boundary default counters
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return InitializeCount + DeinitializeCount + WorldBeginPlayCount;
	}

	/**
	 * Observe Initialize writing 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs Initialize()
	 * @Return InitializeCount
	 */
	UFUNCTION()
	int InitializeNominal()
	{
		Initialize();
		return InitializeCount;
	}
}

UCLASS()
class UCoverageLifecycleGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
	UPROPERTY()
	int InitializeCount = 0;

	UPROPERTY()
	int DeinitializeCount = 0;

	/**
	 * WorldStory: Initialize increments InitializeCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return InitializeCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		InitializeCount++;
	}

	/**
	 * WorldStory: Deinitialize increments DeinitializeCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return DeinitializeCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
		DeinitializeCount++;
	}

	/**
	 * Observe Initialize then Deinitialize.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs Initialize(); Deinitialize()
	 * @Return InitializeCount + DeinitializeCount
	 */
	UFUNCTION()
	int InitializeThenDeinitialize()
	{
		Initialize();
		Deinitialize();
		return InitializeCount + DeinitializeCount;
	}
}
/** @end */
