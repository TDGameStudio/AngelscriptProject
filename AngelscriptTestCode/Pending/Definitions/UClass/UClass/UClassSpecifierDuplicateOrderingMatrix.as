/**
 * @version v1
 * @summary Duplicate Config/metadata last-wins ordering. Config=Game then Config=Editor yields ClassConfigName=Editor; the reverse yields Game. EditorConfigValue defaults to 31; GameConfigValue defaults to 37.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Duplicate Config/metadata last-wins ordering. Config=Game then Config=Editor yields ClassConfigName=Editor; the reverse yields Game. EditorConfigValue defaults to 31; GameConfigValue defaults to 37.
 * @topic Baseline
 */
UCLASS(Config=Game, Config=Editor, DefaultConfig)
class UCoverageUClassConfigLastWinsEditorObject : UObject
{
	UPROPERTY(Config)
	int EditorConfigValue = 31;

	/**
	 * Observe that an unset last-wins-editor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassConfigLastWinsEditorObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassConfigLastWinsEditorObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the EditorConfigValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed object
	 * @Return EditorConfigValue
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return EditorConfigValue;
	}

	/**
	 * Observe writing EditorConfigValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs EditorConfigValue set to 0
	 * @Return EditorConfigValue
	 * @Boundary zero
	 */
	UFUNCTION()
	int ValueZeroBoundary()
	{
		EditorConfigValue = 0;
		return EditorConfigValue;
	}
}

UCLASS(Config=Editor, Config=Game, DefaultConfig)
class UCoverageUClassConfigLastWinsGameObject : UObject
{
	UPROPERTY(Config)
	int GameConfigValue = 37;

	/**
	 * Observe the GameConfigValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed object
	 * @Return GameConfigValue
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return GameConfigValue;
	}
}

UCLASS(ClassGroup="FirstGroup", ClassGroup="SecondGroup", HideCategories="Rendering", HideCategories="Input", meta=(DisplayName="First Display", DisplayName="Second Display", ShortTooltip="First Short", ShortTooltip="Second Short", ToolTip="First ToolTip", ToolTip="Second ToolTip"))
class UCoverageUClassDuplicateMetadataObject : UObject
{
	/**
	 * Observe that an unset duplicate-metadata handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassDuplicateMetadataObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassDuplicateMetadataObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(Blueprintable, NotBlueprintable, Blueprintable, BlueprintType)
class UCoverageUClassRepeatedBlueprintSpecifiersObject : UObject
{
	/**
	 * Observe that an unset repeated-blueprint handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassRepeatedBlueprintSpecifiersObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassRepeatedBlueprintSpecifiersObject Obj;
		return Obj == nullptr;
	}
}
/** @end */
