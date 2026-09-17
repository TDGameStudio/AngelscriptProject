/**
 * @version v1
 * @summary Specifier ordering: last Blueprintable/NotBlueprintable wins. Blueprintable then NotBlueprintable is not a blueprint base; the reverse is.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Specifier ordering: last Blueprintable/NotBlueprintable wins. Blueprintable then NotBlueprintable is not a blueprint base; the reverse is.
 * @topic Baseline
 */
UCLASS(Blueprintable, NotBlueprintable, BlueprintType)
class UCoverageUClassBlueprintOrderNotBaseObject : UObject
{
	/**
	 * Observe that an unset not-base handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassBlueprintOrderNotBaseObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBlueprintOrderNotBaseObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(NotBlueprintable, Blueprintable, BlueprintType)
class UCoverageUClassBlueprintOrderBaseObject : UObject
{
	/**
	 * Observe that an unset base handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassBlueprintOrderBaseObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBlueprintOrderBaseObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(DefaultConfig)
class UCoverageUClassDefaultConfigWithoutConfigObject : UObject
{
	/**
	 * Observe that an unset default-config-without-config handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassDefaultConfigWithoutConfigObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassDefaultConfigWithoutConfigObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(NotPlaceable, Abstract, Blueprintable)
class ACoverageUClassAbstractNotPlaceableActor : AActor
{
	/**
	 * Observe that an unset abstract not-placeable handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassAbstractNotPlaceableActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassAbstractNotPlaceableActor Actor;
		return Actor == nullptr;
	}
}

UCLASS(HideCategories="Rendering", meta=(ShowCategories="Rendering", HideCategories="Input", ClassGroupNames="MetaGroup"))
class ACoverageUClassMetaOverridesActor : AActor
{
	/**
	 * Observe that an unset meta-overrides handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassMetaOverridesActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassMetaOverridesActor Actor;
		return Actor == nullptr;
	}
}

UCLASS(ClassGroup="FirstGroup", meta=(ClassGroupNames="SecondGroup"))
class UCoverageUClassClassGroupOverrideObject : UObject
{
	/**
	 * Observe that an unset class-group-override handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassClassGroupOverrideObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassClassGroupOverrideObject Obj;
		return Obj == nullptr;
	}
}
/** @end */
