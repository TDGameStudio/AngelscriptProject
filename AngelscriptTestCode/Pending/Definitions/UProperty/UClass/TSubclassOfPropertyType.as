/**
 * @version v1
 * @summary A UPROPERTY TSubclassOf<AActor> compiles. The observers cover the null default and assigning AActor::StaticClass() as the live boundary.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY TSubclassOf<AActor> compiles. The observers cover the null default and assigning AActor::StaticClass() as the live boundary.
 * @topic Baseline
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
/** @end */
