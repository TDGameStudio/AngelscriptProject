// Theme: HotReload VersionPair After. Same component metadata, GetVersion 2.
// C++: AngelscriptHotReloadComponentTests.cpp::DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload
// Retained: RootScene root, Billboard attach RootScene, ReplacementBillboard override, live UClass objects.
// Replaced: GetVersion 1 -> 2. Oracle: metadata snapshots equal, GetVersion 2.
// FixtureIsolated. Pair with Before.as.

UCLASS()
class UHotReloadComponentRootComponent : USceneComponent
{
}

UCLASS()
class UHotReloadComponentBillboardComponent : UBillboardComponent
{
}

UCLASS()
class UHotReloadComponentReplacementComponent : UHotReloadComponentBillboardComponent
{
}

UCLASS()
class AHotReloadComponentSoftBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UHotReloadComponentRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UHotReloadComponentBillboardComponent Billboard;
}

UCLASS()
class AHotReloadComponentSoftDerivedActor : AHotReloadComponentSoftBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	UHotReloadComponentReplacementComponent ReplacementBillboard;

	UFUNCTION()
	int GetVersion()
	{
		return 2;
	}
}
