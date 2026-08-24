// Theme: Feature.DefaultComponent. WorldStory DefaultComponent plus OverrideComponent metadata.
// C++: AngelscriptASClassComponentMetadataTests.cpp::DefaultComponentMetadataCapturesRootAndAttachLayout
// Oracle: base records two default components (RootScene is root, Billboard attaches to RootScene);
// derived records one override (ReplacementBillboard overrides Billboard).
// Extra: empty actor / component handles are null. FixtureIsolated.

UCLASS()
class UMetadataRootComponent : USceneComponent
{
}

UCLASS()
class UMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class UMetadataReplacementBillboardComponent : UMetadataBillboardComponent
{
}

UCLASS()
class AMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UMetadataBillboardComponent Billboard;
}

UCLASS()
class AMetadataDerivedActor : AMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	UMetadataReplacementBillboardComponent ReplacementBillboard;
}

bool Observe_MetadataBase_EmptyDefaultIsNull()
{
	AMetadataBaseActor Actor;
	return Actor == nullptr;
}

bool Observe_MetadataDerived_EmptyDefaultIsNull()
{
	AMetadataDerivedActor Actor;
	return Actor == nullptr;
}

bool Observe_MetadataReplacement_EmptyDefaultIsNull()
{
	UMetadataReplacementBillboardComponent Comp;
	return Comp == nullptr;
}
