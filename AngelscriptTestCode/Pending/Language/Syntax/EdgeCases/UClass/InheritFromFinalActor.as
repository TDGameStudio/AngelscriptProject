/**
 * @version v1
 * @summary A class deriving from a final actor. C++ originally expected this to be rejected, but the live C++ wraps it in #if 0 because structural validation is absent: the child compiles. The observers prove the child is a usable.
 * @topic Language
 */
/**
 * @version root
 * @summary A class deriving from a final actor. C++ originally expected this to be rejected, but the live C++ wraps it in #if 0 because structural validation is absent: the child compiles. The observers prove the child is a usable.
 * @topic Baseline
 */
class AFinalInheritActor : AActor final
{
}

class AChildInheritActor : AFinalInheritActor
{
	/**
	 * Observe that the child of the final class is still that class.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AChildInheritActor handle
	 * @Return 1 when the value is an AFinalInheritActor, otherwise 0
	 */
	UFUNCTION()
	int FinalChildIsFinalActor()
	{
		AChildInheritActor Child;
		if (Child is AFinalInheritActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AChildInheritActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalChildDefaultsToNull()
	{
		AChildInheritActor Child;
		if (Child is null)
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
	bool FinalChildAssignAliases()
	{
		AChildInheritActor First;
		AChildInheritActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
