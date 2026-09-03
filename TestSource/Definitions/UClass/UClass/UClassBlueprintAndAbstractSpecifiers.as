/**
 * Blueprintable Abstract versus NotBlueprintable BlueprintType. The abstract
 * class is CLASS_Abstract and IsBlueprintBase; the variable-only class is
 * BlueprintType and not a blueprint base.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassBlueprintAndAbstractSpecifiers
 * @Harness UClass
 * @Tag Definitions.UClass.UClassBlueprintAndAbstractSpecifiers
 * @Provenance Theme: Definitions.UClass. WorldStory Blueprintable Abstract vs NotBlueprintable BlueprintType.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassBlueprintAndAbstractSpecifiers
 * @Provenance Oracle: Abstract CLASS_Abstract + IsBlueprintBase=true; variable-only BlueprintType=true IsBlueprintBase=false.
 * @Provenance Extra: unset handles are null. FixtureIsolated.
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
