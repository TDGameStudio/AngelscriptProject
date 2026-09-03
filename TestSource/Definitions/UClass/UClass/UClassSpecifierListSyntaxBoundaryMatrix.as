/**
 * List-syntax UCLASS specifiers. The current fork does not serialize lists;
 * CLASS_DefaultConfig stays false and ClassGroupNames/HideCategories/DisplayName
 * stay empty.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassSpecifierListSyntaxBoundaryMatrix
 * @Harness UClass
 * @Tag Definitions.UClass.UClassSpecifierListSyntaxBoundaryMatrix
 * @Provenance Theme: Definitions.UClass. Positive list-syntax UCLASS specifiers (current fork does not serialize lists).
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierListSyntaxBoundaryMatrix
 * @Provenance Oracle: CLASS_DefaultConfig is false; ClassGroupNames/HideCategories/DisplayName/ShortTooltip/ToolTip stay empty.
 * @Provenance Extra: unset handle is null; assign aliases. DefaultSafe.
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
