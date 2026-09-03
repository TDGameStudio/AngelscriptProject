/**
 * default Tags/DefaultNames/Mesh configuration. After BeginPlay, NameCount is
 * 3, HasBaseName and HasDerivedName are true, and MeshVisible is false. Keep
 * those UPROPERTY names.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.DefaultKeywordContainersAndComponents
 * @Harness UClass
 * @Tag Definitions.UClass.DefaultKeywordContainersAndComponents
 * @Provenance Theme: Definitions.UClass. WorldStory default Tags/DefaultNames/Mesh configuration.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordContainersAndComponents
 * @Provenance Oracle after BeginPlay: NameCount=3, HasBaseName=true, HasDerivedName=true, MeshVisible=false.
 * @Provenance Extra: unset handle is null; pre-BeginPlay NameCount=0 / MeshVisible=true. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay snapshots tags and mesh visibility.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.DefaultKeyword
	 * @Inputs Tags and Mesh
	 * @Return NameCount, HasBaseName, HasDerivedName, MeshVisible, MeshRelativeLocation updated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NameCount = Tags.Num();
		HasBaseName = Tags.Contains(n"Base");
		HasDerivedName = Tags.Contains(n"Leaf");
		MeshVisible = Mesh.IsVisible();
		MeshRelativeLocation = Mesh.RelativeLocation;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs an unset ACoverageClassFeaturesDefaultContainerComponentActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageClassFeaturesDefaultContainerComponentActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe NameCount before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs a freshly constructed actor
	 * @Return NameCount
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int NameCountBeforeBeginPlay()
	{
		return NameCount;
	}

	/**
	 * Observe MeshVisible before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultKeyword
	 * @Inputs a freshly constructed actor
	 * @Return MeshVisible
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool MeshVisibleDefaultTrue()
	{
		return MeshVisible;
	}
}
