// Theme: HotReload VersionPair Before. Default/override component hierarchy, GetVersion 1.
// C++: AngelscriptHotReloadComponentTests.cpp::DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload
// Retained after soft reload: RootScene, Billboard attach, ReplacementBillboard override, class identity.
// Replaced in After: GetVersion body 1 -> 2. Oracle: two default entries, one override, GetVersion 1.
// FixtureIsolated. Load Before then After in recorded order.

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
		return 1;
	}
}
