/**
 * @version v1
 * @summary DisplayName/ShortTooltip/ToolTip/IsBlueprintBase class meta. DisplayName is "Coverage Metadata Actor". Keep the UCLASS meta block C++ reads.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DisplayName/ShortTooltip/ToolTip/IsBlueprintBase class meta. DisplayName is "Coverage Metadata Actor". Keep the UCLASS meta block C++ reads.
 * @topic Baseline
 */
UCLASS(meta = (
	DisplayName = "Coverage Metadata Actor",
	ShortTooltip = "Short class tooltip",
	ToolTip = "Full class tooltip",
	IsBlueprintBase = "true",
	ChildCanTick,
	IgnoreCategoryKeywordsInSubclasses))
class ACoverageMetaUClassActor : AActor
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset ACoverageMetaUClassActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageMetaUClassActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		ACoverageMetaUClassActor First;
		ACoverageMetaUClassActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
