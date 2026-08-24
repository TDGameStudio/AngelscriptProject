// Theme: Definitions.UClass. Positive ClassGroup/HideCategories/DisplayName/ShowCategories metadata.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDisplayAndCategoryMetadata
// Oracle: ClassGroupNames=Coverage, HideCategories=Rendering, DisplayName/ToolTip/ShortTooltip/IsBlueprintBase round-trip.
// Extra: unset handles are null. DefaultSafe.

UCLASS(ClassGroup="Coverage", HideCategories="Rendering", meta=(DisplayName="Coverage Metadata Object", ToolTip="Full class tooltip", ShortTooltip="Short class tooltip", IsBlueprintBase="true", ChildCanTick, IgnoreCategoryKeywordsInSubclasses))
class UCoverageUClassDisplayMetadataObject : UObject
{
}

UCLASS(HideCategories="Rendering")
class UCoverageUClassHiddenCategoryBaseObject : UObject
{
}

UCLASS(HideCategories="Rendering", meta=(ShowCategories="Rendering", AutoExpandCategories="Coverage", AutoCollapseCategories="Advanced"))
class UCoverageUClassShownCategoryObject : UCoverageUClassHiddenCategoryBaseObject
{
}

bool Observe_DisplayMetadata_EmptyDefaultIsNull()
{
	UCoverageUClassDisplayMetadataObject Obj;
	return Obj == nullptr;
}

bool Observe_HiddenCategoryBase_EmptyDefaultIsNull()
{
	UCoverageUClassHiddenCategoryBaseObject Obj;
	return Obj == nullptr;
}

bool Observe_ShownCategory_EmptyDefaultIsNull()
{
	UCoverageUClassShownCategoryObject Obj;
	return Obj == nullptr;
}

bool Observe_ShownCategory_AssignAliases()
{
	UCoverageUClassShownCategoryObject First;
	UCoverageUClassShownCategoryObject Second;
	First = Second;
	return First is Second;
}
