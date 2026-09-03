/**
 * A derived class may write a protected base field. BaseVal starts at 10;
 * UseBase sets it to 20 from ADerivedActor. Two derived instances stay
 * independent after one of them calls UseBase.
 *
 * @Theme Feature.Access
 * @Subject Access.DerivedProtectedWrite
 * @Harness UClass
 * @Tag Feature.Access.DerivedProtectedWrite
 * @Provenance Theme: Feature.Access. WorldStory: a derived class may write a protected base field.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 5 AssertCompiles.
 * @Provenance Oracle: BaseVal default 10; UseBase sets it to 20 from ADerivedActor.
 * @Provenance Extra: empty/default 10; copy independence. Keep ADerivedActor.UseBase as in C++.
 * @Provenance FixtureIsolated.
 */

class ABaseActor : AActor
{
	protected int BaseVal = 10;
}

class ADerivedActor : ABaseActor
{
	/**
	 * Write the protected base field from the derived type.
	 *
	 * @Covers Access.DerivedProtectedWrite
	 * @Inputs none
	 * @Return nothing; BaseVal becomes 20
	 */
	void UseBase()
	{
		BaseVal = 20;
	}
}

class ADerivedActorReader : ADerivedActor
{
	/**
	 * Read the protected base field from a further derived type.
	 *
	 * @Covers Access.DerivedProtectedWrite
	 * @Inputs none
	 * @Return the current BaseVal
	 */
	int ReadBase()
	{
		return BaseVal;
	}

	/**
	 * Observe that an untouched derived instance holds the protected default of 10.
	 *
	 * @Kind Observe
	 * @Covers Access.DerivedProtectedWrite
	 * @Inputs none
	 * @Return 10, the default of BaseVal
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return ReadBase();
	}

	/**
	 * Observe that UseBase writes the protected field to 20.
	 *
	 * @Kind Observe
	 * @Covers Access.DerivedProtectedWrite
	 * @Inputs UseBase()
	 * @Return 20
	 */
	UFUNCTION()
	int UseBaseWrites20()
	{
		UseBase();
		return ReadBase();
	}

	/**
	 * Observe that driving one instance leaves another instance at the default.
	 *
	 * @Kind Observe
	 * @Covers Access.DerivedProtectedWrite
	 * @Inputs a second derived actor
	 * @Return true when this instance reads 10 and the other reads 20
	 * @Param Second the other actor, driven through UseBase
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ADerivedActorReader Second)
	{
		if (Second is null)
		{
			throw("DerivedProtectedWrite setup: required Second is null");
		}
		Second.UseBase();
		if (ReadBase() != 10)
		{
			return false;
		}
		return Second.ReadBase() == 20;
	}
}
