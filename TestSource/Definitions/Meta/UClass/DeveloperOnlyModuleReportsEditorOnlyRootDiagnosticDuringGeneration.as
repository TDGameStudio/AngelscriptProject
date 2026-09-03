/**
 * A developer-only module still publishes EditorRoot while reporting VerifyClass.
 * bCompiled is true. Keep the EditorRoot name.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
 * @Harness UClass
 * @Tag Definitions.Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
 * @Provenance Theme: Definitions.Meta. WorldStory: developer-only module still publishes EditorRoot while reporting VerifyClass.
 * @Provenance C++: DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration; bCompiled true.
 * @Provenance Extra: default handle is null. FixtureIsolated. Keep EditorRoot name.
 */

UCLASS()
class AComponentVerifyClassDeveloperOnlyBypassActor : AActor
{
	/**
	 * EDITOR keeps EditorRoot as the DefaultComponent RootComponent.
	 *
	 * @Covers Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
	 * @Inputs the flag EDITOR
	 * @Return EditorRoot is declared
	 */
#if EDITOR
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent EditorRoot;
#endif

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AComponentVerifyClassDeveloperOnlyBypassActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that EditorRoot is present in the editor build.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
	 * @Inputs none
	 * @Return true when EditorRoot is not null
	 */
	UFUNCTION()
	bool EditorRootPresent()
	{
		return EditorRoot != nullptr;
	}

	/**
	 * Observe that assigning one unset handle aliases the other.
	 *
	 * @Kind Observe
	 * @Covers Meta.DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration
	 * @Inputs none
	 * @Return true when the assigned handles compare identical
	 * @Boundary assign aliases
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		AComponentVerifyClassDeveloperOnlyBypassActor First;
		AComponentVerifyClassDeveloperOnlyBypassActor Second;
		First = Second;
		return First is Second;
	}
}
