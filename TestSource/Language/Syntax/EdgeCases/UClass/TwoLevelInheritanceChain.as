/**
 * A two-level inheritance chain. A child handle must upcast to its base, stay
 * null until assigned, and alias correctly when copied.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.TwoLevelInheritanceChain
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.TwoLevelInheritanceChain
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 7 AssertCompiles.
 * @Provenance sha256=839eca7f3a83783798913b873439e8916c1b413b810668e96af9000d1cea859c; lines 104-107.
 * @Provenance Oracle: AChildChainActor subclasses ABaseChainActor.
 * @Provenance Extra: default child handle is null; upcast child handle stays a child when set.
 * @Provenance FixtureIsolated.
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
