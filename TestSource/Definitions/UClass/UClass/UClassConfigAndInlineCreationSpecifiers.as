/**
 * Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropdown. Class
 * config name is Game; ConfigValue defaults to 7; EditorValue defaults to 11.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassConfigAndInlineCreationSpecifiers
 * @Harness UClass
 * @Tag Definitions.UClass.UClassConfigAndInlineCreationSpecifiers
 * @Provenance Theme: Definitions.UClass. Positive Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropdown.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassConfigAndInlineCreationSpecifiers
 * @Provenance Oracle: CLASS_Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropDown; ClassConfigName=Game;
 * @Provenance ConfigValue default 7; EditorValue default 11. Extra: unset null; ConfigValue 0 boundary. DefaultSafe.
 */

UCLASS(Config=Game, DefaultConfig, DefaultToInstanced, EditInlineNew, HideDropdown)
class UCoverageUClassConfigInlineObject : UObject
{
	UPROPERTY(Config)
	int ConfigValue = 7;

	/**
	 * Observe that an unset config-inline handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassConfigInlineObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassConfigInlineObject Obj;
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

UCLASS(Config=Editor)
class UCoverageUClassEditorConfigObject : UObject
{
	UPROPERTY(Config)
	int EditorValue = 11;

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
