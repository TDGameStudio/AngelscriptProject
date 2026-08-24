// Theme: Containers.TSoftObjectPtr. WorldStory: construct from FSoftObjectPath, pending, TryLoad.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrPathConstructionAndPending
// CompileScriptModule + spawn + BeginPlay. Oracle: ConstructedFromPath, PendingStateWorked,
// CrossLevelPathStored, ResourcePathCanResolve true.
// Extra: local construct leaves flags false; missing texture stays pending.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSoftRefPathConstructionActor : AActor
{
	UPROPERTY()
	TSoftObjectPtr<UTexture2D> TextureFromPath;

	UPROPERTY()
	TSoftObjectPtr<AActor> CrossLevelActorPath;

	UPROPERTY()
	bool ConstructedFromPath = false;

	UPROPERTY()
	bool PendingStateWorked = false;

	UPROPERTY()
	bool CrossLevelPathStored = false;

	UPROPERTY()
	bool ResourcePathCanResolve = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FSoftObjectPath TexturePath("/Engine/EngineResources/DefaultTexture.DefaultTexture");
		TextureFromPath = TSoftObjectPtr<UTexture2D>(TexturePath);
		ConstructedFromPath = TextureFromPath.ToSoftObjectPath() == TexturePath && TextureFromPath.ToString() == TexturePath.ToString();

		TSoftObjectPtr<UTexture2D> MissingTexture(FSoftObjectPath("/Game/Coverage/MissingTexture.MissingTexture"));
		PendingStateWorked = !MissingTexture.IsNull() && !MissingTexture.IsValid() && MissingTexture.IsPending();

		CrossLevelActorPath = TSoftObjectPtr<AActor>(FSoftObjectPath("/Game/Coverage/OtherMap.OtherMap:PersistentLevel.OtherActor"));
		CrossLevelPathStored = CrossLevelActorPath.IsPending() && CrossLevelActorPath.ToString().Contains("PersistentLevel");

		UObject ResolvedTexture = TextureFromPath.ToSoftObjectPath().TryLoad();
		ResourcePathCanResolve = Cast<UTexture2D>(ResolvedTexture) != nullptr;
	}
}

bool Observe_SoftPathConstruction_DefaultEmpty(ACoverageSoftRefPathConstructionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrPathConstructionAndPending setup: required Actor is null");
	}
	return Actor.ConstructedFromPath == false
		&& Actor.PendingStateWorked == false
		&& Actor.CrossLevelPathStored == false
		&& Actor.ResourcePathCanResolve == false
		&& Actor.TextureFromPath.IsNull();
}

bool Observe_SoftPathConstruction_MissingPending()
{
	TSoftObjectPtr<UTexture2D> MissingTexture(FSoftObjectPath("/Game/Coverage/MissingTexture.MissingTexture"));
	return !MissingTexture.IsNull() && !MissingTexture.IsValid() && MissingTexture.IsPending();
}

bool Observe_SoftPathConstruction_CopyIndependence()
{
	FSoftObjectPath TexturePath("/Engine/EngineResources/DefaultTexture.DefaultTexture");
	TSoftObjectPtr<UTexture2D> First(TexturePath);
	TSoftObjectPtr<UTexture2D> Second;
	return !First.IsNull() && Second.IsNull();
}
