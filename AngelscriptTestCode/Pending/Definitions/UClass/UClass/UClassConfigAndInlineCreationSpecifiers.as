/**
 * @version v1
 * @summary Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropdown. Class config name is Game; ConfigValue defaults to 7; EditorValue defaults to 11.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropdown. Class config name is Game; ConfigValue defaults to 7; EditorValue defaults to 11.
 * @topic Baseline
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
/** @end */
