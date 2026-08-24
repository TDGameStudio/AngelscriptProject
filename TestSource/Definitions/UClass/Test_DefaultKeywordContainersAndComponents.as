// Theme: Definitions.UClass. WorldStory default Tags/DefaultNames/Mesh configuration.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordContainersAndComponents
// Oracle after BeginPlay: NameCount=3, HasBaseName=true, HasDerivedName=true, MeshVisible=false.
// Extra: unset handle is null; pre-BeginPlay NameCount=0 / MeshVisible=true. FixtureIsolated.

UCLASS()
class ACoverageClassFeaturesDefaultContainerComponentActor : AActor
{
	UPROPERTY()
	TArray<FName> DefaultNames;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UStaticMeshComponent Mesh;

	default Tags.Add(n"Base");
	default Tags.Add(n"Shared");
	default Tags.Add(n"Leaf");
	default DefaultNames.Add(n"Base");
	default DefaultNames.Add(n"Shared");
	default DefaultNames.Add(n"Leaf");
	default Mesh.SetCastShadow(false);
	default Mesh.SetRelativeLocation(FVector(12.0f, 34.0f, 56.0f));
	default Mesh.SetVisibility(false);

	UPROPERTY()
	int NameCount = 0;

	UPROPERTY()
	bool HasBaseName = false;

	UPROPERTY()
	bool HasDerivedName = false;

	UPROPERTY()
	bool MeshCastShadow = true;

	UPROPERTY()
	bool MeshVisible = true;

	UPROPERTY()
	FVector MeshRelativeLocation;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NameCount = Tags.Num();
		HasBaseName = Tags.Contains(n"Base");
		HasDerivedName = Tags.Contains(n"Leaf");
		MeshVisible = Mesh.IsVisible();
		MeshRelativeLocation = Mesh.RelativeLocation;
	}
}

bool Observe_DefaultContainer_EmptyDefaultIsNull()
{
	ACoverageClassFeaturesDefaultContainerComponentActor Actor;
	return Actor == nullptr;
}

int Observe_DefaultContainer_NameCountBeforeBeginPlay(ACoverageClassFeaturesDefaultContainerComponentActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0028 setup: required ACoverageClassFeaturesDefaultContainerComponentActor is null");
	}
	return Actor.NameCount;
}

bool Observe_DefaultContainer_MeshVisibleDefaultTrue(ACoverageClassFeaturesDefaultContainerComponentActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0028 setup: required ACoverageClassFeaturesDefaultContainerComponentActor is null");
	}
	return Actor.MeshVisible;
}
