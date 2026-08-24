// Theme: Definitions.UClass. WorldStory full supported-specifier cross product plus inherited combinations.
// C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierCrossProductMatrix
// Oracle: all-specifiers actor keeps Abstract/Transient/Deprecated/NotPlaceable; ConfigValue default 101; EditorValue 202.
// Extra: unset handles are null; ConfigValue 0 boundary. FixtureIsolated.

UCLASS(Blueprintable, BlueprintType, Abstract, Transient, Deprecated, NotPlaceable, Config=Game, DefaultConfig, DefaultToInstanced, EditInlineNew, HideDropdown, ClassGroup="CoverageGroup", HideCategories="Rendering", ComponentWrapperClass, meta=(DisplayName="Coverage All Specifiers", ToolTip="All supported specifiers", ShortTooltip="All specifiers", ConversionRoot, HideFunctions="HiddenA,HiddenB", SparseClassDataTypes="SparseData", AutoExpandCategories="Expanded", AutoCollapseCategories="Collapsed", CollapseCategories, DontCollapseCategories, ChildCanTick))
class ACoverageUClassAllSupportedSpecifiersActor : AActor
{
	UPROPERTY(Config)
	int ConfigValue = 101;
}

UCLASS(NotBlueprintable, BlueprintType, Config=Editor, DefaultToInstanced)
class UCoverageUClassVariableOnlyConfigObject : UObject
{
	UPROPERTY(Config)
	int EditorValue = 202;
}

UCLASS(Transient, Deprecated, DefaultToInstanced, EditInlineNew, Config=Game, DefaultConfig)
class UCoverageUClassCombinationBaseObject : UObject
{
}

UCLASS(Blueprintable)
class UCoverageUClassCombinationChildObject : UCoverageUClassCombinationBaseObject
{
}

bool Observe_AllSupportedSpecifiers_EmptyDefaultIsNull()
{
	ACoverageUClassAllSupportedSpecifiersActor Actor;
	return Actor == nullptr;
}

int Observe_AllSupportedSpecifiers_ConfigValueDefault(ACoverageUClassAllSupportedSpecifiersActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0157 setup: required ACoverageUClassAllSupportedSpecifiersActor is null");
	}
	return Actor.ConfigValue;
}

int Observe_AllSupportedSpecifiers_ConfigValueZeroBoundary(ACoverageUClassAllSupportedSpecifiersActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0157 setup: required ACoverageUClassAllSupportedSpecifiersActor is null");
	}
	Actor.ConfigValue = 0;
	return Actor.ConfigValue;
}

int Observe_VariableOnlyConfig_EditorValueDefault(UCoverageUClassVariableOnlyConfigObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0157 setup: required UCoverageUClassVariableOnlyConfigObject is null");
	}
	return Obj.EditorValue;
}

bool Observe_CombinationChild_EmptyDefaultIsNull()
{
	UCoverageUClassCombinationChildObject Obj;
	return Obj == nullptr;
}
