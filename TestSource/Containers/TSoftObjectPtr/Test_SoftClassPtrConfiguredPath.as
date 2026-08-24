// Theme: Containers.TSoftObjectPtr. WorldStory: Config TSoftClassPtr path, load, spawn, pending.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftClassPtrConfiguredPath
// CompileScriptModule + spawn + BeginPlay. Oracle: ConstructedFromConfiguredPath,
// LoadedConfiguredClass, ConfiguredClassCanSpawn, PendingConfiguredPath true.
// Extra: local construct leaves flags false; missing class stays pending.
// FixtureIsolated. Runner owns spawned actors.

UCLASS(Config=Game)
class ACoverageSoftClassConfiguredPathActor : AActor
{
	UPROPERTY(Config)
	TSoftClassPtr<AActor> ConfiguredActorClass;

	UPROPERTY()
	bool ConstructedFromConfiguredPath = false;

	UPROPERTY()
	bool LoadedConfiguredClass = false;

	UPROPERTY()
	bool ConfiguredClassCanSpawn = false;

	UPROPERTY()
	bool PendingConfiguredPath = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ConfiguredActorClass = TSoftClassPtr<AActor>(FSoftObjectPath("/Script/Engine.Actor"));
		ConstructedFromConfiguredPath = ConfiguredActorClass.ToString().Contains("Actor");

		TSubclassOf<AActor> LoadedClass = ConfiguredActorClass.Get();
		LoadedConfiguredClass = LoadedClass.IsValid() && LoadedClass.IsChildOf(AActor::StaticClass());

		AActor SpawnedActor = SpawnActor(LoadedClass);
		ConfiguredClassCanSpawn = SpawnedActor != nullptr;

		TSoftClassPtr<AActor> MissingConfiguredClass(FSoftObjectPath("/Game/Coverage/MissingActorClass.MissingActorClass_C"));
		PendingConfiguredPath = !MissingConfiguredClass.IsNull() && !MissingConfiguredClass.IsValid() && MissingConfiguredClass.IsPending();
	}
}

bool Observe_SoftClassConfigured_DefaultEmpty(ACoverageSoftClassConfiguredPathActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftClassPtrConfiguredPath setup: required Actor is null");
	}
	return Actor.ConstructedFromConfiguredPath == false
		&& Actor.LoadedConfiguredClass == false
		&& Actor.ConfiguredClassCanSpawn == false
		&& Actor.PendingConfiguredPath == false
		&& Actor.ConfiguredActorClass.IsNull();
}

bool Observe_SoftClassConfigured_MissingPending()
{
	TSoftClassPtr<AActor> MissingConfiguredClass(FSoftObjectPath("/Game/Coverage/MissingActorClass.MissingActorClass_C"));
	return !MissingConfiguredClass.IsNull() && !MissingConfiguredClass.IsValid() && MissingConfiguredClass.IsPending();
}

bool Observe_SoftClassConfigured_CopyIndependence(ACoverageSoftClassConfiguredPathActor First, ACoverageSoftClassConfiguredPathActor Second)
{
	if (First is null)
	{
		throw("Test_SoftClassPtrConfiguredPath setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SoftClassPtrConfiguredPath setup: required Second is null");
	}
	First.ConfiguredActorClass = TSoftClassPtr<AActor>(FSoftObjectPath("/Script/Engine.Actor"));
	return !First.ConfiguredActorClass.IsNull() && Second.ConfiguredActorClass.IsNull();
}
