/**
 * @version v1
 * @summary ClassGroup/HideCategories/DisplayName/ShowCategories metadata. ClassGroupNames is Coverage; HideCategories is Rendering.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ClassGroup/HideCategories/DisplayName/ShowCategories metadata. ClassGroupNames is Coverage; HideCategories is Rendering.
 * @topic Baseline
 */
UCLASS(ClassGroup="Coverage", HideCategories="Rendering", meta=(DisplayName="Coverage Metadata Object", ToolTip="Full class tooltip", ShortTooltip="Short class tooltip", IsBlueprintBase="true", ChildCanTick, IgnoreCategoryKeywordsInSubclasses))
class UCoverageUClassDisplayMetadataObject : UObject
{
	/**
	 * Observe that an unset display-metadata handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset UCoverageUClassDisplayMetadataObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassDisplayMetadataObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(HideCategories="Rendering")
class UCoverageUClassHiddenCategoryBaseObject : UObject
{
	/**
	 * Observe that an unset hidden-category handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset UCoverageUClassHiddenCategoryBaseObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassHiddenCategoryBaseObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(HideCategories="Rendering", meta=(ShowCategories="Rendering", AutoExpandCategories="Coverage", AutoCollapseCategories="Advanced"))
class UCoverageUClassShownCategoryObject : UCoverageUClassHiddenCategoryBaseObject
{
	/**
	 * Observe that an unset shown-category handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset UCoverageUClassShownCategoryObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassShownCategoryObject Obj;
		return Obj == nullptr;
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
		UCoverageUClassShownCategoryObject First;
		UCoverageUClassShownCategoryObject Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
