// Theme: Definitions.Meta. WorldStory: developer-only module still publishes EditorRoot while reporting VerifyClass.
// C++: DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration; bCompiled true.
// Extra: default handle is null. FixtureIsolated. Keep EditorRoot name.

UCLASS()
class AComponentVerifyClassDeveloperOnlyBypassActor : AActor
{
	#if EDITOR
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent EditorRoot;
	#endif
}

int Observe_DeveloperOnlyRoot_EmptyDefaultIsNull()
{
	AComponentVerifyClassDeveloperOnlyBypassActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_DeveloperOnlyRoot_EditorRootPresent(AComponentVerifyClassDeveloperOnlyBypassActor Actor)
{
	return Actor.EditorRoot != nullptr;
}

bool Observe_DeveloperOnlyRoot_AssignAliases()
{
	AComponentVerifyClassDeveloperOnlyBypassActor First;
	AComponentVerifyClassDeveloperOnlyBypassActor Second;
	First = Second;
	return First is Second;
}
