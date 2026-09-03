/**
 * A UPROPERTY TSubclassOf<AActor> compiles. The observers cover the null default
 * and assigning AActor::StaticClass() as the live boundary.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TSubclassOfPropertyType
 * @Harness UClass
 * @Tag Definitions.UProperty.TSubclassOfPropertyType
 * @Provenance Theme: Definitions.UProperty. WorldStory: UPROPERTY TSubclassOf<AActor>.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
 * @Provenance UPropTP_TSubclassOf; lines 442-448;
 * @Provenance sha256=afada7c27457809f02ecd40ed365fabe4f87005fd976a9428bb34802fe9b4b6d.
 * @Provenance Oracle: ActorClass default is null on the spawned actor.
 * @Provenance Extra: null is the empty/default; assigning AActor::StaticClass() is the live boundary.
 * @Provenance FixtureIsolated.
 */

class AUPropSubclassActor : AActor
{
	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	/**
	 * Observe the default ActorClass of null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TSubclassOfPropertyType
	 * @Inputs none
	 * @Return true when ActorClass is null
	 */
	UFUNCTION()
	bool ActorClassDefault()
	{
		return ActorClass == nullptr;
	}

	/**
	 * Observe that the empty default is null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TSubclassOfPropertyType
	 * @Inputs none
	 * @Return true when ActorClass is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool ActorClassEmptyDefault()
	{
		return ActorClass == nullptr;
	}

	/**
	 * Observe assigning AActor::StaticClass() then restoring null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TSubclassOfPropertyType
	 * @Inputs ActorClass assigned to AActor::StaticClass() then restored
	 * @Return true when the assignment is non-null and the saved default is null
	 * @Boundary live class
	 */
	UFUNCTION()
	bool ActorClassAssignBoundary()
	{
		TSubclassOf<AActor> Saved = ActorClass;
		ActorClass = AActor::StaticClass();
		bool bAssigned = ActorClass != nullptr;
		ActorClass = Saved;
		if (!bAssigned)
		{
			return false;
		}
		return Saved == nullptr;
	}
}
