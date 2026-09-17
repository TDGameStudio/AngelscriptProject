/**
 * @version v1
 * @summary An actor subclass declared without the A prefix. C++ originally expected the naming convention to be enforced, but the live C++ wraps this in #if 0: the class compiles, so the CSV NegativeDiagnostic is not a.
 * @topic Language
 */
/**
 * @version root
 * @summary An actor subclass declared without the A prefix. C++ originally expected the naming convention to be enforced, but the live C++ wraps this in #if 0: the class compiles, so the CSV NegativeDiagnostic is not a.
 * @topic Baseline
 */
class MyActor : AActor
{
	/**
	 * Observe that the unprefixed class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed MyActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int UnprefixedActorIsAnActor()
	{
		MyActor Actor;
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
	 * @Inputs an unset MyActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int UnprefixedActorDefaultsToNull()
	{
		MyActor Unset;
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
	bool UnprefixedActorAssignAliases()
	{
		MyActor First;
		MyActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
