/**
 * The this keyword used to disambiguate a member assignment from a parameter of
 * the same role. The observers confirm the write lands on the member, that the
 * member starts at zero, and that instances do not share state.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.ThisKeywordMemberAssignment
 * @Harness UClass
 * @Tag Language.Syntax.Keywords.ThisKeywordMemberAssignment
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 1 AssertCompiles.
 * @Provenance sha256=725539f37361e9c48be2628aaccf770a652b819c847de033fc2f723b5ec86a2d; lines 108-118.
 * @Provenance Oracle: SetX(5) writes X=5 via this. Extra: default X is 0; SetX(0) stays 0;
 * @Provenance a second instance stays 0. FixtureIsolated.
 */

class AActorThis : AActor
{
	int X = 0;

	/**
	 * Assigns the member through the this keyword.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs a new value for X
	 * @Return nothing; this.X receives the value
	 * @Param Val the value to assign
	 */
	void SetX(int Val)
	{
		this.X = Val;
	}

	/**
	 * Observe that a write through this lands on the member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs SetX(5) then this.X
	 * @Return 5
	 */
	UFUNCTION()
	int ThisWriteLandsOnMember()
	{
		SetX(5);
		return X;
	}

	/**
	 * Observe that the member starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int ThisMemberDefaultsToZero()
	{
		return X;
	}

	/**
	 * Observe the zero boundary of the this write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs SetX(0) then this.X
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ThisWriteZeroBoundary()
	{
		SetX(0);
		return X;
	}

	/**
	 * Observe that writing this instance leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 8 and the other stays 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ThisWriteIsIndependentAcrossInstances()
	{
		AActorThis Other;
		SetX(8);

		if (X != 8)
		{
			return false;
		}

		return Other.X == 0;
	}
}
