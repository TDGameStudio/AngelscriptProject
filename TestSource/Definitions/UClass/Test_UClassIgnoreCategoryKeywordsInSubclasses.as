// Theme: Definitions.UClass. Positive IgnoreCategoryKeywordsInSubclasses inheritance cut-off.
// C++: AngelscriptCoverageUClassTests.cpp::UClassIgnoreCategoryKeywordsInSubclasses
// Oracle: base HideCategories/AutoExpand/AutoCollapse round-trip; child does not inherit those keys.
// Extra: unset handles are null. DefaultSafe.

UCLASS(HideCategories="Rendering", meta=(AutoExpandCategories="Coverage", AutoCollapseCategories="Advanced", IgnoreCategoryKeywordsInSubclasses, HideFunctions="CoverageIgnoredFunction", SparseClassDataTypes="CoverageIgnoredSparseData"))
class UCoverageUClassIgnoredCategoryBaseObject : UObject
{
}

UCLASS()
class UCoverageUClassIgnoredCategoryChildObject : UCoverageUClassIgnoredCategoryBaseObject
{
}

bool Observe_IgnoredCategoryBase_EmptyDefaultIsNull()
{
	UCoverageUClassIgnoredCategoryBaseObject Obj;
	return Obj == nullptr;
}

bool Observe_IgnoredCategoryChild_EmptyDefaultIsNull()
{
	UCoverageUClassIgnoredCategoryChildObject Obj;
	return Obj == nullptr;
}

bool Observe_IgnoredCategoryChild_AssignAliases()
{
	UCoverageUClassIgnoredCategoryChildObject First;
	UCoverageUClassIgnoredCategoryChildObject Second;
	First = Second;
	return First is Second;
}
