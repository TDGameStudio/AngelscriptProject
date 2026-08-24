// Theme: Definitions.Meta. WorldStory: #if EDITOR RootComponent still publishes the actor (handled compile + diagnostic).
// C++: EditorOnlyRootRejectedForRuntimeActor; bCompiled true. CSV NegativeDiagnostic is wrong.
// Extra: default handle is null; EditorRoot is editor-only. FixtureIsolated.

UCLASS()
class AComponentVerifyClassEditorOnlyRootActor : AActor
{
	#if EDITOR
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent EditorRoot;
	#endif
}

int Observe_EditorOnlyRoot_EmptyDefaultIsNull()
{
	AComponentVerifyClassEditorOnlyRootActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_EditorOnlyRoot_AssignAliases()
{
	AComponentVerifyClassEditorOnlyRootActor First;
	AComponentVerifyClassEditorOnlyRootActor Second;
	First = Second;
	return First is Second;
}

bool Observe_EditorOnlyRoot_EditorRootPresent(AComponentVerifyClassEditorOnlyRootActor Actor)
{
	return Actor.EditorRoot != nullptr;
}
