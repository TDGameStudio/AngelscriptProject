/**
 * Full supported-specifier cross product plus inherited combinations. The
 * all-specifiers actor keeps Abstract/Transient/Deprecated/NotPlaceable;
 * ConfigValue defaults to 101; EditorValue defaults to 202.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassSpecifierCrossProductMatrix
 * @Harness UClass
 * @Tag Definitions.UClass.UClassSpecifierCrossProductMatrix
 * @Provenance Theme: Definitions.UClass. WorldStory full supported-specifier cross product plus inherited combinations.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierCrossProductMatrix
 * @Provenance Oracle: all-specifiers actor keeps Abstract/Transient/Deprecated/NotPlaceable; ConfigValue default 101; EditorValue 202.
 * @Provenance Extra: unset handles are null; ConfigValue 0 boundary. FixtureIsolated.
 */

UCLASS(Blueprintable, BlueprintType, Abstract, Transient, Deprecated, NotPlaceable, Config=Game, DefaultConfig, DefaultToInstanced, EditInlineNew, HideDropdown, ClassGroup="CoverageGroup", HideCategories="Rendering", ComponentWrapperClass, meta=(DisplayName="Coverage All Specifiers", ToolTip="All supported specifiers", ShortTooltip="All specifiers", ConversionRoot, HideFunctions="HiddenA,HiddenB", SparseClassDataTypes="SparseData", AutoExpandCategories="Expanded", AutoCollapseCategories="Collapsed", CollapseCategories, DontCollapseCategories, ChildCanTick))
class ACoverageUClassAllSupportedSpecifiersActor : AActor
{
	UPROPERTY(Config)
	int ConfigValue = 101;

	/**
	 * Observe that an unset all-specifiers handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassAllSupportedSpecifiersActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassAllSupportedSpecifiersActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the ConfigValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed actor
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

UCLASS(NotBlueprintable, BlueprintType, Config=Editor, DefaultToInstanced)
class UCoverageUClassVariableOnlyConfigObject : UObject
{
	UPROPERTY(Config)
	int EditorValue = 202;

	/**
	 * Observe the EditorValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed object
	 * @Return EditorValue
	 */
	UFUNCTION()
	int EditorValueDefault()
	{
		return EditorValue;
	}
}

UCLASS(Transient, Deprecated, DefaultToInstanced, EditInlineNew, Config=Game, DefaultConfig)
class UCoverageUClassCombinationBaseObject : UObject
{
}

UCLASS(Blueprintable)
class UCoverageUClassCombinationChildObject : UCoverageUClassCombinationBaseObject
{
	/**
	 * Observe that an unset combination-child handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassCombinationChildObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassCombinationChildObject Obj;
		return Obj == nullptr;
	}
}
