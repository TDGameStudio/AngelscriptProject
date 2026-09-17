/**
 * @version v1
 * @summary #if EDITOR keeps ActiveBranchValue and GetBranchValue. GetBranchValue reports 57. InactiveBranchValue is not reflected in the editor build.
 * @topic Definitions
 */
/**
 * @version root
 * @summary #if EDITOR keeps ActiveBranchValue and GetBranchValue. GetBranchValue reports 57. InactiveBranchValue is not reflected in the editor build.
 * @topic Baseline
 */
UCLASS()
class ACoverageMacrosEditorConditionActor : AActor
{
	/**
	 * The accepted condition: EDITOR is a supported flag, so the members inside it are kept.
	 *
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs the flag EDITOR
	 * @Return the members below are declared
	 */
#if EDITOR
	UPROPERTY()
	int ActiveBranchValue = 57;

	/**
	 * Return the editor-side branch value.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs none
	 * @Return ActiveBranchValue
	 */
	UFUNCTION()
	int GetBranchValue() const
	{
		return ActiveBranchValue;
	}

	/**
	 * Observe that writing zero still reads back through GetBranchValue.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		ActiveBranchValue = 0;
		return GetBranchValue();
	}
#else
	UPROPERTY()
	int InactiveBranchValue = -1;

	/**
	 * Return the non-editor branch value.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs none
	 * @Return InactiveBranchValue
	 */
	UFUNCTION()
	int GetBranchValue() const
	{
		return InactiveBranchValue;
	}
#endif

	/**
	 * Observe that GetBranchValue reports the active branch.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs none
	 * @Return 57 in editor
	 */
	UFUNCTION()
	int BranchValueNominal()
	{
		return GetBranchValue();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditorConditionActiveBranchReflects
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageMacrosEditorConditionActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
