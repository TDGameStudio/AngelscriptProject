/**
 * @version v1
 * @summary An empty AActor subclass. The class must compile and behave as an AActor, with its handle null until assigned.
 * @topic Language
 */
/**
 * @version root
 * @summary An empty AActor subclass. The class must compile and behave as an AActor, with its handle null until assigned.
 * @topic Baseline
 */
class AClassBasicActor : AActor
{
	/**
	 * Observe that the empty subclass is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassBasicActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int EmptySubclassIsAnActor()
	{
		AClassBasicActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassBasicActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptySubclassDefaultsToNull()
	{
		AClassBasicActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool EmptySubclassAssignAliases()
	{
		AClassBasicActor First;
		AClassBasicActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
