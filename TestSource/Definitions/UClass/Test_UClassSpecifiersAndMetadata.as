// Theme: Definitions.UClass. Positive specifier/metadata bundle on a UObject.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::UClassSpecifiersAndMetadata
// Oracle: CLASS_DefaultToInstanced/EditInlineNew/HideDropDown/Config/DefaultConfig, ClassConfigName=Game,
// ConfigValue CPF_Config, ClassGroupNames=Coverage. Script oracle: ConfigValue default 7.
// Extra: unset handle is null; ConfigValue 0 boundary. DefaultSafe.

UCLASS(DefaultToInstanced, EditInlineNew, HideDropdown, Config=Game, DefaultConfig, ClassGroup="Coverage", HideCategories="Rendering", ComponentWrapperClass, meta=(DisplayName="Coverage Specifier Object", ShortTooltip="Short coverage tooltip", ToolTip="Full coverage tooltip", IsBlueprintBase="true", ChildCanTick, IgnoreCategoryKeywordsInSubclasses))
class UCoverageSpecifierObject : UObject
{
	UPROPERTY(Config)
	int ConfigValue = 7;
}

bool Observe_SpecifierObject_EmptyDefaultIsNull()
{
	UCoverageSpecifierObject Obj;
	return Obj == nullptr;
}

int Observe_SpecifierObject_ConfigValueDefault(UCoverageSpecifierObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0029 setup: required UCoverageSpecifierObject is null");
	}
	return Obj.ConfigValue;
}

int Observe_SpecifierObject_ConfigValueZeroBoundary(UCoverageSpecifierObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0029 setup: required UCoverageSpecifierObject is null");
	}
	Obj.ConfigValue = 0;
	return Obj.ConfigValue;
}
