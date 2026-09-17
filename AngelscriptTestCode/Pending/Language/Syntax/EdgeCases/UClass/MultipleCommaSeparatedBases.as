/**
 * @version v1
 * @summary A class declaring two comma-separated base classes. C++ originally expected multi-base inheritance to be rejected, but the live C++ wraps this in #if 0 because structural validation is absent: the class compiles. The.
 * @topic Language
 */
/**
 * @version root
 * @summary A class declaring two comma-separated base classes. C++ originally expected multi-base inheritance to be rejected, but the live C++ wraps this in #if 0 because structural validation is absent: the class compiles. The.
 * @topic Baseline
 */
class AClassMultiBaseActor : AActor, APawn
{
	/**
	 * Observe that the multi-base class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassMultiBaseActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int MultiBaseActorIsAnActor()
	{
		AClassMultiBaseActor Actor;
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
	 * @Inputs an unset AClassMultiBaseActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MultiBaseActorDefaultsToNull()
	{
		AClassMultiBaseActor Unset;
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
	bool MultiBaseActorAssignAliases()
	{
		AClassMultiBaseActor First;
		AClassMultiBaseActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
