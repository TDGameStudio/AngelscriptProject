/**
 * @version v1
 * @summary UObject, AActor, UActorComponent, and USceneComponent UCLASS bases. Each generated class is a child of the matching native base.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UObject, AActor, UActorComponent, and USceneComponent UCLASS bases. Each generated class is a child of the matching native base.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassBaseObject : UObject
{
	/**
	 * Observe that an unset object handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassBaseObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBaseObject Obj;
		return Obj == nullptr;
	}
}

UCLASS()
class ACoverageUClassBaseActor : AActor
{
	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset ACoverageUClassBaseActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassBaseActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		ACoverageUClassBaseActor First;
		ACoverageUClassBaseActor Second;
		First = Second;
		return First is Second;
	}
}

UCLASS()
class UCoverageUClassBaseActorComponent : UActorComponent
{
	/**
	 * Observe that an unset actor-component handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassBaseActorComponent handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBaseActorComponent Comp;
		return Comp == nullptr;
	}
}

UCLASS()
class UCoverageUClassBaseSceneComponent : USceneComponent
{
	/**
	 * Observe that an unset scene-component handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassBaseSceneComponent handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBaseSceneComponent Comp;
		return Comp == nullptr;
	}
}
/** @end */
