// Theme: Definitions.UClass. WorldStory script subsystem Initialize/Deinitialize/OnWorldBeginPlay.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::SubsystemLifecycleReflectionBoundaries
// Oracle: BP_Initialize / BP_Deinitialize / BP_OnWorldBeginPlay UFunctions exist on generated classes.
// Extra: unset handles are null; default counters 0; Initialize then Deinitialize. FixtureIsolated.

UCLASS()
class UCoverageLifecycleWorldSubsystem : UScriptWorldSubsystem
{
	UPROPERTY()
	int InitializeCount = 0;

	UPROPERTY()
	int DeinitializeCount = 0;

	UPROPERTY()
	int WorldBeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		InitializeCount++;
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
		DeinitializeCount++;
	}

	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
		WorldBeginPlayCount++;
	}
}

UCLASS()
class UCoverageLifecycleGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
	UPROPERTY()
	int InitializeCount = 0;

	UPROPERTY()
	int DeinitializeCount = 0;

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		InitializeCount++;
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
		DeinitializeCount++;
	}
}

bool Observe_WorldSubsystem_EmptyDefaultIsNull()
{
	UCoverageLifecycleWorldSubsystem Sub;
	return Sub == nullptr;
}

int Observe_WorldSubsystem_CountersDefault(UCoverageLifecycleWorldSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0048 setup: required UCoverageLifecycleWorldSubsystem is null");
	}
	return Sub.InitializeCount + Sub.DeinitializeCount + Sub.WorldBeginPlayCount;
}

int Observe_WorldSubsystem_InitializeNominal(UCoverageLifecycleWorldSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0048 setup: required UCoverageLifecycleWorldSubsystem is null");
	}
	Sub.Initialize();
	return Sub.InitializeCount;
}

int Observe_GameInstanceSubsystem_InitializeThenDeinitialize(UCoverageLifecycleGameInstanceSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0048 setup: required UCoverageLifecycleGameInstanceSubsystem is null");
	}
	Sub.Initialize();
	Sub.Deinitialize();
	return Sub.InitializeCount + Sub.DeinitializeCount;
}
