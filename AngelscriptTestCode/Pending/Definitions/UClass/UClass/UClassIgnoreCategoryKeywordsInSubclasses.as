/**
 * @version v1
 * @summary IgnoreCategoryKeywordsInSubclasses inheritance cut-off. The base publishes HideCategories/AutoExpand/AutoCollapse; the child does not inherit those keys.
 * @topic Definitions
 */
/**
 * @version root
 * @summary IgnoreCategoryKeywordsInSubclasses inheritance cut-off. The base publishes HideCategories/AutoExpand/AutoCollapse; the child does not inherit those keys.
 * @topic Baseline
 */
UCLASS(HideCategories="Rendering", meta=(AutoExpandCategories="Coverage", AutoCollapseCategories="Advanced", IgnoreCategoryKeywordsInSubclasses, HideFunctions="CoverageIgnoredFunction", SparseClassDataTypes="CoverageIgnoredSparseData"))
class UCoverageUClassIgnoredCategoryBaseObject : UObject
{
	/**
	 * Observe that an unset base handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset UCoverageUClassIgnoredCategoryBaseObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassIgnoredCategoryBaseObject Obj;
		return Obj == nullptr;
	}
}

UCLASS()
class UCoverageUClassIgnoredCategoryChildObject : UCoverageUClassIgnoredCategoryBaseObject
{
	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Meta
	 * @Inputs an unset UCoverageUClassIgnoredCategoryChildObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassIgnoredCategoryChildObject Obj;
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
		UCoverageUClassIgnoredCategoryChildObject First;
		UCoverageUClassIgnoredCategoryChildObject Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
