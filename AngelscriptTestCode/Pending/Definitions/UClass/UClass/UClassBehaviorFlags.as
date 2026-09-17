/**
 * @version v1
 * @summary Transient/Deprecated/NotPlaceable versus a default-placeable actor. C++ checks CLASS_Transient, CLASS_Deprecated, CLASS_NotPlaceable, and placeable.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Transient/Deprecated/NotPlaceable versus a default-placeable actor. C++ checks CLASS_Transient, CLASS_Deprecated, CLASS_NotPlaceable, and placeable.
 * @topic Baseline
 */
UCLASS(Transient, Deprecated)
class UCoverageUClassTransientDeprecatedObject : UObject
{
	/**
	 * Observe that an unset transient/deprecated handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassTransientDeprecatedObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassTransientDeprecatedObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(NotPlaceable)
class ACoverageUClassNotPlaceableActor : AActor
{
	/**
	 * Observe that an unset not-placeable handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassNotPlaceableActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassNotPlaceableActor Actor;
		return Actor == nullptr;
	}
}

UCLASS()
class ACoverageUClassDefaultPlaceableActor : AActor
{
	/**
	 * Observe that an unset placeable handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassDefaultPlaceableActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassDefaultPlaceableActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		ACoverageUClassDefaultPlaceableActor First;
		ACoverageUClassDefaultPlaceableActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
