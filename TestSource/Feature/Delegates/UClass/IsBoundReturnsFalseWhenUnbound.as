/**
 * Unicast IsBound on an empty delegate. RunIsBoundTest returns 1 on the
 * unbound path. A second local stays unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.IsBoundReturnsFalseWhenUnbound
 * @Harness UClass
 * @Tag Feature.Delegates.IsBoundReturnsFalseWhenUnbound
 * @Provenance Theme: Feature.Delegates. WorldStory unicast IsBound on an empty delegate.
 * @Provenance C++: AngelscriptDelegateTests.cpp::IsBoundReturnsFalseWhenUnbound
 * @Provenance sha256=084e2e3e1aaf1a267f97d67bc1c2721946db8085240518131e5aef3954928b3c; lines 123-140.
 * @Provenance Oracle: RunIsBoundTest returns 1 (unbound path). Extra: default IsBound is false;
 * @Provenance a second local stays unbound. FixtureIsolated.
 */

/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.IsBound
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FSimpleNotify();

UCLASS()
class ATestDelegateIsBound : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	/**
	 * Returns 1 when OnNotify is unbound, otherwise 10.
	 *
	 * @Covers Delegates.IsBound
	 * @Inputs none
	 * @Return 1 when unbound
	 */
	UFUNCTION()
	int RunIsBoundTest()
	{
		if (OnNotify.IsBound())
		{
			return 10;
		}
		return 1;
	}

	/**
	 * Observe the unbound path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.IsBound
	 * @Inputs RunIsBoundTest()
	 * @Return 1
	 * @Boundary unbound
	 */
	UFUNCTION()
	int UnboundReturnsOne()
	{
		return RunIsBoundTest();
	}

	/**
	 * Observe that OnNotify starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.IsBound
	 * @Inputs this
	 * @Return true when OnNotify is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DefaultUnbound()
	{
		return !OnNotify.IsBound();
	}

	/**
	 * Observe that a second actor also takes the unbound path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.IsBound
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs RunIsBoundTest on this and Second
	 * @Return true when both return 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent(ATestDelegateIsBound Second)
	{
		if (Second is null)
		{
			throw("IsBoundReturnsFalseWhenUnbound setup: required Second is null");
		}
		if (RunIsBoundTest() != 1)
		{
			return false;
		}
		return Second.RunIsBoundTest() == 1;
	}
}
