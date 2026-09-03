/**
 * DefaultComponent/ShowOnActor on a non-actor UObject owner. The owner is not
 * an AActor; DefaultComponent metadata stays property-local; Logic is the
 * component type.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassNonActorComponentSpecifierMetadataBoundary
 * @Harness UClass
 * @Tag Definitions.UClass.UClassNonActorComponentSpecifierMetadataBoundary
 * @Provenance Theme: Definitions.UClass. WorldStory DefaultComponent/ShowOnActor on a non-actor UObject owner.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassNonActorComponentSpecifierMetadataBoundary
 * @Provenance Oracle: owner is not an AActor; DefaultComponent metadata stays property-local; Logic is the component type.
 * @Provenance Extra: unset handles are null; Logic default is null. FixtureIsolated.
 */

UCLASS()
class UCoverageUClassNonActorSpecifierComponent : UActorComponent
{
	/**
	 * Observe that an unset component handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset UCoverageUClassNonActorSpecifierComponent handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassNonActorSpecifierComponent Comp;
		return Comp == nullptr;
	}
}

UCLASS()
class UCoverageUClassNonActorComponentSpecifierBaseOwner : UObject
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UCoverageUClassNonActorSpecifierComponent Logic;

	/**
	 * Observe that an unset owner handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset UCoverageUClassNonActorComponentSpecifierBaseOwner handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassNonActorComponentSpecifierBaseOwner Owner;
		return Owner == nullptr;
	}

	/**
	 * Observe that Logic defaults to null on a non-actor owner.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs a freshly constructed owner
	 * @Return true when Logic is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool LogicDefaultIsNull()
	{
		return Logic == nullptr;
	}
}
