// Theme: Feature.DefaultComponent. HotReload version pair V1.
// C++: AngelscriptASClassComponentMetadataTests.cpp::SoftReloadPreservesDefaultComponentMetadataWithoutDuplication block 1
// Oracle: two default-component entries, one override entry; GetVersion()==1.
// Retained after reload: RootScene / Billboard / ReplacementBillboard layout.
// Replaced later: GetVersion body. Extra: empty actor is null. FixtureIsolated.

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
		return 1;
	}
}

bool Observe_SoftReloadV1_EmptyDefaultIsNull()
{
	ASoftMetadataDerivedActor Actor;
	return Actor == nullptr;
}

int Observe_SoftReloadV1_GetVersion(ASoftMetadataDerivedActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0233 setup: required ASoftMetadataDerivedActor is null");
	}
	return Actor.GetVersion();
}
