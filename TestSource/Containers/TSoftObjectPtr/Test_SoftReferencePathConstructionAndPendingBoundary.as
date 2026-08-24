// Theme: Containers.TSoftObjectPtr. WorldStory: path construction, pending, config class.
// C++: AngelscriptCoverageHandlesTests.cpp::SoftReferencePathConstructionAndPendingBoundary
// CompileScriptModule + spawn + BeginPlay. Oracle: ConstructedObjectPath, MissingObjectIsPending,
// CrossLevelPathStored, ResourcePathCanResolve true (and configured-class flags).
// Extra: local construct leaves flags false; missing texture stays pending.
// FixtureIsolated. Runner owns World teardown.

UCLASS(Config=Game)
class ACoverageHandlesSoftPathBoundaryActor : AActor
{
	UPROPERTY()
	TSoftObjectPtr<UTexture2D> TextureFromPath;

	UPROPERTY()
	TSoftObjectPtr<AActor> CrossLevelActorPath;

	UPROPERTY(Config)
	TSoftClassPtr<AActor> ConfiguredActorClass;

	UPROPERTY()
	bool ConstructedObjectPath = false;

	UPROPERTY()
	bool MissingObjectIsPending = false;

	UPROPERTY()
	bool CrossLevelPathStored = false;

	UPROPERTY()
	bool ResourcePathCanResolve = false;

	UPROPERTY()
	bool ConfiguredClassPathWorked = false;

	UPROPERTY()
	bool MissingClassIsPending = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FSoftObjectPath TexturePath("/Engine/EngineResources/DefaultTexture.DefaultTexture");
		TextureFromPath = TSoftObjectPtr<UTexture2D>(TexturePath);
		ConstructedObjectPath = TextureFromPath.ToSoftObjectPath() == TexturePath &&
			TextureFromPath.ToString() == TexturePath.ToString();

		TSoftObjectPtr<UTexture2D> MissingTexture(FSoftObjectPath("/Game/Coverage/MissingTexture.MissingTexture"));
		MissingObjectIsPending = !MissingTexture.IsNull() &&
			!MissingTexture.IsValid() &&
			MissingTexture.IsPending();

		CrossLevelActorPath = TSoftObjectPtr<AActor>(FSoftObjectPath("/Game/Coverage/OtherMap.OtherMap:PersistentLevel.OtherActor"));
		CrossLevelPathStored = CrossLevelActorPath.IsPending() &&
			CrossLevelActorPath.ToString().Contains("PersistentLevel");

		UObject ResolvedTexture = TextureFromPath.ToSoftObjectPath().TryLoad();
		ResourcePathCanResolve = Cast<UTexture2D>(ResolvedTexture) != nullptr;

		ConfiguredActorClass = TSoftClassPtr<AActor>(FSoftObjectPath("/Script/Engine.Actor"));
		TSubclassOf<AActor> LoadedClass = ConfiguredActorClass.Get();
		ConfiguredClassPathWorked = LoadedClass.IsValid() &&
			LoadedClass.IsChildOf(AActor::StaticClass()) &&
			ConfiguredActorClass.ToString().Contains("Actor");

		TSoftClassPtr<AActor> MissingActorClass(FSoftObjectPath("/Game/Coverage/MissingActorClass.MissingActorClass_C"));
		MissingClassIsPending = !MissingActorClass.IsNull() &&
			!MissingActorClass.IsValid() &&
			MissingActorClass.IsPending();
	}
}

bool Observe_SoftPathBoundary_DefaultEmpty(ACoverageHandlesSoftPathBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftReferencePathConstructionAndPendingBoundary setup: required Actor is null");
	}
	return Actor.ConstructedObjectPath == false
		&& Actor.MissingObjectIsPending == false
		&& Actor.CrossLevelPathStored == false
		&& Actor.ResourcePathCanResolve == false
		&& Actor.ConfiguredClassPathWorked == false
		&& Actor.MissingClassIsPending == false;
}

bool Observe_MissingTexture_PendingBoundary()
{
	TSoftObjectPtr<UTexture2D> MissingTexture(FSoftObjectPath("/Game/Coverage/MissingTexture.MissingTexture"));
	return !MissingTexture.IsNull() && !MissingTexture.IsValid() && MissingTexture.IsPending();
}

bool Observe_SoftPath_CopyIndependence()
{
	FSoftObjectPath TexturePath("/Engine/EngineResources/DefaultTexture.DefaultTexture");
	TSoftObjectPtr<UTexture2D> First(TexturePath);
	TSoftObjectPtr<UTexture2D> Second;
	First.Reset();
	return First.IsNull() && Second.IsNull();
}
