// Theme: Feature.DefaultComponent. HotReload version pair V2.
// C++: AngelscriptASClassComponentMetadataTests.cpp::SoftReloadPreservesDefaultComponentMetadataWithoutDuplication block 2
// Oracle: default/override metadata counts stay 2/1; GetVersion()==2.
// Retained: RootScene / Billboard / ReplacementBillboard layout.
// Replaced: GetVersion body (1 -> 2). Extra: empty actor is null. FixtureIsolated.

UCLASS()
class USoftMetadataRootComponent : USceneComponent
{
}

UCLASS()
class USoftMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class USoftMetadataReplacementBillboardComponent : USoftMetadataBillboardComponent
{
}

UCLASS()
class ASoftMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USoftMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USoftMetadataBillboardComponent Billboard;
}

UCLASS()
class ASoftMetadataDerivedActor : ASoftMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	USoftMetadataReplacementBillboardComponent ReplacementBillboard;

	UFUNCTION()
	int GetVersion()
	{
		return 2;
	}
}

bool Observe_SoftReloadV2_EmptyDefaultIsNull()
{
	ASoftMetadataDerivedActor Actor;
	return Actor == nullptr;
}

int Observe_SoftReloadV2_GetVersion(ASoftMetadataDerivedActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0234 setup: required ASoftMetadataDerivedActor is null");
	}
	return Actor.GetVersion();
}
