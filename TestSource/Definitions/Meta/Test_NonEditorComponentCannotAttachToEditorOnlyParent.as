// Theme: Definitions.Meta. WorldStory: runtime Billboard attached to #if EDITOR parent still compiles with VerifyClass diagnostic.
// C++: NonEditorComponentCannotAttachToEditorOnlyParent; bCompiled true (CSV is not a hard fail).
// Extra: default handle is null; RootScene remains the runtime root. FixtureIsolated.

UCLASS()
class AComponentVerifyClassEditorOnlyParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	#if EDITOR
	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent EditorParent;
	#endif

	UPROPERTY(DefaultComponent, Attach = EditorParent)
	UBillboardComponent RuntimeBillboard;
}

int Observe_EditorOnlyParent_EmptyDefaultIsNull()
{
	AComponentVerifyClassEditorOnlyParentActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_EditorOnlyParent_RootPresent(AComponentVerifyClassEditorOnlyParentActor Actor)
{
	return Actor.RootScene != nullptr;
}

bool Observe_EditorOnlyParent_RuntimeBillboardPresent(AComponentVerifyClassEditorOnlyParentActor Actor)
{
	return Actor.RuntimeBillboard != nullptr;
}
