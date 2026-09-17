/**
 * @version v1
 * @summary A two-level inheritance chain. A child handle must upcast to its base, stay null until assigned, and alias correctly when copied.
 * @topic Language
 */
/**
 * @version root
 * @summary A two-level inheritance chain. A child handle must upcast to its base, stay null until assigned, and alias correctly when copied.
 * @topic Baseline
 */
class ABaseChainActor : AActor
{
}

class AChildChainActor : ABaseChainActor
{
	/**
	 * Observe that a child handle upcasts to the base type.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a child handle assigned to a base handle
	 * @Return 1 when the base handle is an ABaseChainActor, otherwise 0
	 */
	UFUNCTION()
	int ChainChildUpcastsToBase()
	{
		AChildChainActor Child;
		ABaseChainActor Base = Child;
		if (Base is ABaseChainActor)
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
	 * @Inputs an unset AChildChainActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int ChainChildDefaultsToNull()
	{
		AChildChainActor Child;
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
	bool ChainChildAssignAliases()
	{
		AChildChainActor First;
		AChildChainActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
