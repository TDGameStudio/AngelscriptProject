// Theme: Definitions.UClass. WorldStory script subsystem ShouldCreateSubsystem plus lifecycle ticks.
// C++: AngelscriptCoverageUClassTests.cpp::UClassSubsystemFunctionSurface
// Oracle: BP_ShouldCreateSubsystem / BP_Initialize / BP_Deinitialize / BP_PostInitialize / BP_OnWorldBeginPlay exist.
// Extra: unset handles are null; ShouldCreateSubsystem(nullptr)=false. FixtureIsolated.

UCLASS()
class UCoverageUClassSurfaceWorldSubsystem : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void PostInitialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnWorldComponentsUpdated()
	{
	}

	UFUNCTION(BlueprintOverride)
	void UpdateStreamingState()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}
}

UCLASS()
class UCoverageUClassSurfaceGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}
}

UCLASS()
class UCoverageUClassSurfaceLocalPlayerSubsystem : UScriptLocalPlayerSubsystem
{
	UFUNCTION(BlueprintOverride)
	bool ShouldCreateSubsystem(UObject Outer) const
	{
		return Outer != nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}
}

bool Observe_SurfaceWorldSubsystem_EmptyDefaultIsNull()
{
	UCoverageUClassSurfaceWorldSubsystem Sub;
	return Sub == nullptr;
}

bool Observe_SurfaceWorldSubsystem_ShouldCreateNullOuter(UCoverageUClassSurfaceWorldSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0155 setup: required UCoverageUClassSurfaceWorldSubsystem is null");
	}
	return Sub.ShouldCreateSubsystem(nullptr) == false;
}

bool Observe_SurfaceGameInstanceSubsystem_ShouldCreateNullOuter(UCoverageUClassSurfaceGameInstanceSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0155 setup: required UCoverageUClassSurfaceGameInstanceSubsystem is null");
	}
	return Sub.ShouldCreateSubsystem(nullptr) == false;
}

bool Observe_SurfaceLocalPlayerSubsystem_ShouldCreateNullOuter(UCoverageUClassSurfaceLocalPlayerSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0155 setup: required UCoverageUClassSurfaceLocalPlayerSubsystem is null");
	}
	return Sub.ShouldCreateSubsystem(nullptr) == false;
}

int Observe_SurfaceWorldSubsystem_EmptyLifecycleCompletes(UCoverageUClassSurfaceWorldSubsystem Sub)
{
	if (Sub == nullptr)
	{
		throw("TS-DEF-0155 setup: required UCoverageUClassSurfaceWorldSubsystem is null");
	}
	Sub.Initialize();
	Sub.PostInitialize();
	Sub.OnWorldBeginPlay();
	Sub.Tick(0.0f);
	Sub.Deinitialize();
	return 0;
}
