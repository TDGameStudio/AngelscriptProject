/**
 * The override keyword applied to a child method that shadows a parent method.
 * Both the empty parent body and the empty child body must complete.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.OverrideKeywordOnChildMethod
 * @Harness UClass
 * @Tag Language.Syntax.Keywords.OverrideKeywordOnChildMethod
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 4 AssertCompiles.
 * @Provenance sha256=4111136a58863104cc677f5b2e967e8380d0f9e8d61335f00a72965ccc536f56; lines 144-154.
 * @Provenance Oracle: AChildActorOvrd.Foo() override is an empty body that completes.
 * @Provenance Extra: ABaseActorOvrd.Foo() also completes; assigning child aliases shares the handle.
 * @Provenance FixtureIsolated.
 */

class ABaseActorOvrd : AActor
{
	/**
	 * The parent method that the child overrides.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo()
	{
	}
}

class AChildActorOvrd : ABaseActorOvrd
{
	/**
	 * The child method carrying the override keyword.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo() override
	{
	}

	/**
	 * Observe that the overriding method completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs Foo() on the child
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int OverrideMethodCompletes()
	{
		Foo();
		return 0;
	}

	/**
	 * Observe that the parent method also completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs Foo() on the base
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int BaseMethodCompletes()
	{
		ABaseActorOvrd Base;
		Base.Foo();
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool ChildHandleAssignAliases()
	{
		AChildActorOvrd First;
		AChildActorOvrd Second;
		First = Second;
		return First is Second;
	}
}
