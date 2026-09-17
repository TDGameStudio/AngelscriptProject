/**
 * @version v1
 * @summary Script subsystem ShouldCreateSubsystem plus lifecycle ticks. C++ looks up BP_ShouldCreateSubsystem / BP_Initialize / BP_Deinitialize / BP_PostInitialize / BP_OnWorldBeginPlay. ShouldCreateSubsystem(nullptr) is false.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Script subsystem ShouldCreateSubsystem plus lifecycle ticks. C++ looks up BP_ShouldCreateSubsystem / BP_Initialize / BP_Deinitialize / BP_PostInitialize / BP_OnWorldBeginPlay. ShouldCreateSubsystem(nullptr) is false.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassSurfaceWorldSubsystem : UScriptWorldSubsystem
{
	/**
	 * WorldStory: ShouldCreateSubsystem is true only when Outer is non-null.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Param Outer Outer object
	 * @Inputs Outer
	 * @Return true when Outer is non-null
	 */
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	/**
	 * WorldStory: Initialize is the world-subsystem initialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	/**
	 * WorldStory: Deinitialize is the world-subsystem deinitialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	/**
	 * WorldStory: PostInitialize is the world-subsystem post-initialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void PostInitialize()
	{
	}

	/**
	 * WorldStory: OnWorldBeginPlay is the world-begin-play override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
	}

	/**
	 * WorldStory: OnWorldComponentsUpdated is the components-updated override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnWorldComponentsUpdated()
	{
	}

	/**
	 * WorldStory: UpdateStreamingState is the streaming-state override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void UpdateStreamingState()
	{
	}

	/**
	 * WorldStory: Tick is the world-subsystem tick override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Param DeltaTime Frame delta
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}

	/**
	 * Observe that an unset world-subsystem handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs an unset UCoverageUClassSurfaceWorldSubsystem handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassSurfaceWorldSubsystem Sub;
		return Sub == nullptr;
	}

	/**
	 * Observe ShouldCreateSubsystem(nullptr).
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs ShouldCreateSubsystem(nullptr)
	 * @Return true when the result is false
	 * @Boundary null outer
	 */
	UFUNCTION()
	bool ShouldCreateNullOuter()
	{
		return ShouldCreateSubsystem(nullptr) == false;
	}

	/**
	 * Observe that empty Initialize/PostInitialize/OnWorldBeginPlay/Tick/Deinitialize complete.
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs the empty lifecycle sequence
	 * @Return 0
	 * @Boundary empty lifecycle
	 */
	UFUNCTION()
	int EmptyLifecycleCompletes()
	{
		Initialize();
		PostInitialize();
		OnWorldBeginPlay();
		Tick(0.0f);
		Deinitialize();
		return 0;
	}
}

UCLASS()
class UCoverageUClassSurfaceGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
	/**
	 * WorldStory: ShouldCreateSubsystem is true only when Outer is non-null.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Param Outer Outer object
	 * @Inputs Outer
	 * @Return true when Outer is non-null
	 */
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	/**
	 * WorldStory: Initialize is the game-instance-subsystem initialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	/**
	 * WorldStory: Deinitialize is the game-instance-subsystem deinitialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	/**
	 * WorldStory: Tick is the game-instance-subsystem tick override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Param DeltaTime Frame delta
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}

	/**
	 * Observe ShouldCreateSubsystem(nullptr).
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs ShouldCreateSubsystem(nullptr)
	 * @Return true when the result is false
	 * @Boundary null outer
	 */
	UFUNCTION()
	bool ShouldCreateNullOuter()
	{
		return ShouldCreateSubsystem(nullptr) == false;
	}
}

UCLASS()
class UCoverageUClassSurfaceLocalPlayerSubsystem : UScriptLocalPlayerSubsystem
{
	/**
	 * WorldStory: ShouldCreateSubsystem is true only when Outer is non-null.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Param Outer Outer object
	 * @Inputs Outer
	 * @Return true when Outer is non-null
	 */
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	/**
	 * WorldStory: Initialize is the local-player-subsystem initialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	/**
	 * WorldStory: Deinitialize is the local-player-subsystem deinitialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Subsystem
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	/**
	 * Observe ShouldCreateSubsystem(nullptr).
	 *
	 * @Kind Observe
	 * @Covers UClass.Subsystem
	 * @Inputs ShouldCreateSubsystem(nullptr)
	 * @Return true when the result is false
	 * @Boundary null outer
	 */
	UFUNCTION()
	bool ShouldCreateNullOuter()
	{
		return ShouldCreateSubsystem(nullptr) == false;
	}
}
/** @end */
