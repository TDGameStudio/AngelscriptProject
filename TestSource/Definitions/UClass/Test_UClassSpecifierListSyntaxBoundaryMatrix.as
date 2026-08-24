// Theme: Definitions.UClass. Positive list-syntax UCLASS specifiers (current fork does not serialize lists).
// C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierListSyntaxBoundaryMatrix
// Oracle: CLASS_DefaultConfig is false; ClassGroupNames/HideCategories/DisplayName/ShortTooltip/ToolTip stay empty.
// Extra: unset handle is null; assign aliases. DefaultSafe.

UCLASS(ClassGroup=(ListGroup), HideCategories=(Rendering,Input), DefaultConfig=(Ignored), ComponentWrapperClass=(Ignored), meta=(DisplayName=("List Display"), ShortTooltip=("List Short"), ToolTip=("List ToolTip"), ShowCategories=(Rendering,Input), AutoExpandCategories=(Coverage,Advanced), AutoCollapseCategories=(Collapsed), HideFunctions=(HiddenA,HiddenB), SparseClassDataTypes=(SparseA,SparseB), ConversionRoot=(Ignored), ChildCanTick=(Ignored), CollapseCategories=(Ignored), DontCollapseCategories=(Ignored)))
class UCoverageUClassListSyntaxObject : UObject
{
}

bool Observe_ListSyntaxObject_EmptyDefaultIsNull()
{
	UCoverageUClassListSyntaxObject Obj;
	return Obj == nullptr;
}

bool Observe_ListSyntaxObject_AssignAliases()
{
	UCoverageUClassListSyntaxObject First;
	UCoverageUClassListSyntaxObject Second;
	First = Second;
	return First is Second;
}
