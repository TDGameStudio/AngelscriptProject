/**
 * @version v1
 * @summary List-syntax UCLASS specifiers. The current fork does not serialize lists; CLASS_DefaultConfig stays false and ClassGroupNames/HideCategories/DisplayName stay empty.
 * @topic Definitions
 */
/**
 * @version root
 * @summary List-syntax UCLASS specifiers. The current fork does not serialize lists; CLASS_DefaultConfig stays false and ClassGroupNames/HideCategories/DisplayName stay empty.
 * @topic Baseline
 */
UCLASS(ClassGroup=(ListGroup), HideCategories=(Rendering,Input), DefaultConfig=(Ignored), ComponentWrapperClass=(Ignored), meta=(DisplayName=("List Display"), ShortTooltip=("List Short"), ToolTip=("List ToolTip"), ShowCategories=(Rendering,Input), AutoExpandCategories=(Coverage,Advanced), AutoCollapseCategories=(Collapsed), HideFunctions=(HiddenA,HiddenB), SparseClassDataTypes=(SparseA,SparseB), ConversionRoot=(Ignored), ChildCanTick=(Ignored), CollapseCategories=(Ignored), DontCollapseCategories=(Ignored)))
class UCoverageUClassListSyntaxObject : UObject
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassListSyntaxObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassListSyntaxObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		UCoverageUClassListSyntaxObject First;
		UCoverageUClassListSyntaxObject Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
