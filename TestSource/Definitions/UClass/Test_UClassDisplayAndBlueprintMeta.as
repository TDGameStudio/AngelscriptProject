// Theme: Definitions.UClass. WorldStory DisplayName/ShortTooltip/ToolTip/IsBlueprintBase meta.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UClassDisplayAndBlueprintMeta
// Oracle: DisplayName="Coverage Metadata Actor", ShortTooltip/ToolTip round-trip, IsBlueprintBase=true.
// Extra: unset handle is null; assign aliases. FixtureIsolated.

UCLASS(meta = (
	DisplayName = "Coverage Metadata Actor",
	ShortTooltip = "Short class tooltip",
	ToolTip = "Full class tooltip",
	IsBlueprintBase = "true",
	ChildCanTick,
	IgnoreCategoryKeywordsInSubclasses))
class ACoverageMetaUClassActor : AActor
{
}

bool Observe_MetaUClassActor_EmptyDefaultIsNull()
{
	ACoverageMetaUClassActor Actor;
	return Actor == nullptr;
}

bool Observe_MetaUClassActor_AssignAliases()
{
	ACoverageMetaUClassActor First;
	ACoverageMetaUClassActor Second;
	First = Second;
	return First is Second;
}
