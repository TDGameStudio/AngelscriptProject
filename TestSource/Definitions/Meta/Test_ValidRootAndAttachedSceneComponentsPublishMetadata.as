// Theme: Definitions.Meta. WorldStory: RootComponent plus Attach=RootScene default components.
// C++: AngelscriptComponentMetadataValidationTests.cpp::ValidRootAndAttachedSceneComponentsPublishMetadata
// Oracle: RootScene is root; Billboard attaches to RootScene. Extra: default handle is null.
// FixtureIsolated. Keep RootScene / Billboard names.

UCLASS()
class AComponentVerifyClassValidActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent Billboard;
}

int Observe_ValidComponents_EmptyDefaultIsNull()
{
	AComponentVerifyClassValidActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ValidComponents_AssignAliases()
{
	AComponentVerifyClassValidActor First;
	AComponentVerifyClassValidActor Second;
	First = Second;
	return First is Second;
}

bool Observe_ValidComponents_RootAndBillboardPresent(AComponentVerifyClassValidActor Actor)
{
	return Actor.RootScene != nullptr && Actor.Billboard != nullptr;
}

bool Observe_ValidComponents_BillboardAttachedToRoot(AComponentVerifyClassValidActor Actor)
{
	if (Actor.RootScene == nullptr || Actor.Billboard == nullptr)
	{
		return false;
	}
	return Actor.Billboard.GetAttachParent() == Actor.RootScene;
}
