/**
 * @version v1
 * @summary An #if EDITOR RootComponent still publishes the actor (handled compile plus diagnostic). CSV NegativeDiagnostic is wrong; bCompiled is true. EditorRoot is editor-only.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An #if EDITOR RootComponent still publishes the actor (handled compile plus diagnostic). CSV NegativeDiagnostic is wrong; bCompiled is true. EditorRoot is editor-only.
 * @topic Baseline
 */
UCLASS()
class AComponentVerifyClassEditorOnlyRootActor : AActor
{
	/**
	 * EDITOR keeps EditorRoot as the DefaultComponent RootComponent.
	 *
	 * @Covers Meta.EditorOnlyRootRejectedForRuntimeActor
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
	 * @Covers Meta.EditorOnlyRootRejectedForRuntimeActor
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AComponentVerifyClassEditorOnlyRootActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one unset handle aliases the other.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorOnlyRootRejectedForRuntimeActor
	 * @Inputs none
	 * @Return true when the assigned handles compare identical
	 * @Boundary assign aliases
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		AComponentVerifyClassEditorOnlyRootActor First;
		AComponentVerifyClassEditorOnlyRootActor Second;
		First = Second;
		return First is Second;
	}

	/**
	 * Observe that EditorRoot is present in the editor build.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorOnlyRootRejectedForRuntimeActor
	 * @Inputs none
	 * @Return true when EditorRoot is not null
	 */
	UFUNCTION()
	bool EditorRootPresent()
	{
		return EditorRoot != nullptr;
	}
}
/** @end */
