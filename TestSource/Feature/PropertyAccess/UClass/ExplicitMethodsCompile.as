/**
 * Explicit GetHealth/SetHealth methods on a script actor. C++ AssertCompiles this
 * WorldStory. Default GetHealth() is 100; Test() writes 5. Observers cover SetHealth(0)
 * and copy independence of two instances.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.ExplicitMethodsCompile
 * @Harness UClass
 * @Tag Feature.PropertyAccess.ExplicitMethodsCompile
 * @Provenance Theme: Feature.PropertyAccess. WorldStory explicit GetHealth/SetHealth methods.
 * @Provenance C++: AngelscriptSyntaxPropertyAccessorTests.cpp::ExplicitMethodsCompile AssertCompiles.
 * @Provenance Oracle: default GetHealth()==100; Test() writes 5.
 * @Provenance Extra: SetHealth(0); copy independence of two instances.
 * @Provenance FixtureIsolated.
 */

class AActorPAExplicit : AActor
{
	private int _Health = 100;

	/**
	 * WorldStory: GetHealth returns the private health field.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs none
	 * @Return the current _Health
	 */
	int GetHealth() const
	{
		return _Health;
	}

	/**
	 * WorldStory: SetHealth writes the private health field.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs the value to store
	 * @Return void; _Health is Value
	 * @Param Value the health to store
	 */
	void SetHealth(int Value)
	{
		_Health = Value;
	}

	/**
	 * WorldStory: Test writes health to 5 through SetHealth.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs none
	 * @Return void; GetHealth() is 5
	 */
	void Test()
	{
		SetHealth(5);
		int Current = GetHealth();
	}

	/**
	 * Observe the default health before Test or SetHealth.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs none
	 * @Return 100
	 * @Boundary default GetHealth
	 */
	UFUNCTION()
	int PAExplicit_DefaultHealth()
	{
		return GetHealth();
	}

	/**
	 * Observe that Test writes health to 5.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs none
	 * @Return 5 after Test()
	 */
	UFUNCTION()
	int PAExplicit_TestWritesFive()
	{
		Test();
		return GetHealth();
	}

	/**
	 * Observe SetHealth(0) as a zero boundary.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs none
	 * @Return 0 after SetHealth(0)
	 * @Boundary SetHealth(0)
	 */
	UFUNCTION()
	int PAExplicit_ZeroBoundary()
	{
		SetHealth(0);
		return GetHealth();
	}

	/**
	 * Observe that writing this actor leaves another actor at default health.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.ExplicitMethodsCompile
	 * @Inputs a second actor that must stay at its default
	 * @Return true when this is 5 and the other stays 100
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PAExplicit_CopyIndependence(AActorPAExplicit Second)
	{
		if (Second is null)
		{
			throw("ExplicitMethodsCompile setup: required Second is null");
		}
		SetHealth(5);
		if (GetHealth() != 5)
		{
			return false;
		}
		return Second.GetHealth() == 100;
	}
}
