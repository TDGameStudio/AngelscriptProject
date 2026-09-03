/**
 * Specifier/metadata bundle on a UObject. CLASS_DefaultToInstanced/EditInlineNew/
 * HideDropDown/Config/DefaultConfig, ClassConfigName=Game, ConfigValue CPF_Config,
 * ClassGroupNames=Coverage. ConfigValue defaults to 7.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassSpecifiersAndMetadata
 * @Harness UClass
 * @Tag Definitions.UClass.UClassSpecifiersAndMetadata
 * @Provenance Theme: Definitions.UClass. Positive specifier/metadata bundle on a UObject.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::UClassSpecifiersAndMetadata
 * @Provenance Oracle: CLASS_DefaultToInstanced/EditInlineNew/HideDropDown/Config/DefaultConfig, ClassConfigName=Game,
 * @Provenance ConfigValue CPF_Config, ClassGroupNames=Coverage. Script oracle: ConfigValue default 7.
 * @Provenance Extra: unset handle is null; ConfigValue 0 boundary. DefaultSafe.
 */

UCLASS(DefaultToInstanced, EditInlineNew, HideDropdown, Config=Game, DefaultConfig, ClassGroup="Coverage", HideCategories="Rendering", ComponentWrapperClass, meta=(DisplayName="Coverage Specifier Object", ShortTooltip="Short coverage tooltip", ToolTip="Full coverage tooltip", IsBlueprintBase="true", ChildCanTick, IgnoreCategoryKeywordsInSubclasses))
class UCoverageSpecifierObject : UObject
{
	UPROPERTY(Config)
	int ConfigValue = 7;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageSpecifierObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageSpecifierObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the ConfigValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed object
	 * @Return ConfigValue
	 */
	UFUNCTION()
	int ConfigValueDefault()
	{
		return ConfigValue;
	}

	/**
	 * Observe writing ConfigValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs ConfigValue set to 0
	 * @Return ConfigValue
	 * @Boundary zero
	 */
	UFUNCTION()
	int ConfigValueZeroBoundary()
	{
		ConfigValue = 0;
		return ConfigValue;
	}
}
