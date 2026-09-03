/**
 * UObject, AActor, UActorComponent, and USceneComponent UCLASS bases. Each
 * generated class is a child of the matching native base.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassBaseTypeDeclarations
 * @Harness UClass
 * @Tag Definitions.UClass.UClassBaseTypeDeclarations
 * @Provenance Theme: Definitions.UClass. WorldStory UObject/AActor/UActorComponent/USceneComponent UCLASS bases.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassBaseTypeDeclarations
 * @Provenance Oracle: each generated class is a child of the matching native base.
 * @Provenance Extra: unset handles are null; assign aliases. FixtureIsolated.
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
