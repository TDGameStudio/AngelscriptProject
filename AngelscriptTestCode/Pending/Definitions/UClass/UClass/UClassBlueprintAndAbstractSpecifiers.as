/**
 * @version v1
 * @summary Blueprintable Abstract versus NotBlueprintable BlueprintType. The abstract class is CLASS_Abstract and IsBlueprintBase; the variable-only class is BlueprintType and not a blueprint base.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Blueprintable Abstract versus NotBlueprintable BlueprintType. The abstract class is CLASS_Abstract and IsBlueprintBase; the variable-only class is BlueprintType and not a blueprint base.
 * @topic Baseline
 */
UCLASS(Blueprintable, Abstract)
class ACoverageUClassAbstractBlueprintableActor : AActor
{
	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset ACoverageUClassAbstractBlueprintableActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassAbstractBlueprintableActor Actor;
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
		ACoverageUClassAbstractBlueprintableActor First;
		ACoverageUClassAbstractBlueprintableActor Second;
		First = Second;
		return First is Second;
	}
}

UCLASS(NotBlueprintable, BlueprintType)
class UCoverageUClassBlueprintVariableOnlyObject : UObject
{
	/**
	 * Observe that an unset variable-only handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UCoverageUClassBlueprintVariableOnlyObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassBlueprintVariableOnlyObject Obj;
		return Obj == nullptr;
	}
}
/** @end */
