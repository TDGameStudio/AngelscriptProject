/**
 * An AActor subclass whose members carry initializers: an int set to 100 and a
 * float set to 5. The observers read both defaults, push the int to its empty
 * boundary, and show that writing one instance does not write another.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ActorMembersWithInitializers
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.ActorMembersWithInitializers
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 2 AssertCompiles.
 * @Provenance sha256=855e8529441c5fbb2e1e7513a52802fcb8d84316c8e0f558e311c38dc66844aa; lines 56-62.
 * @Provenance Oracle: Health defaults to 100; Speed defaults to 5.0f.
 * @Provenance Extra: Health 0 is the empty/false boundary; mutating one instance does not
 * @Provenance write the other. FixtureIsolated.
 */

class AClassMembersActor : AActor
{
	int Health = 100;
	float Speed = 5.0f;

	/**
	 * Observe the initialized integer default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the Health value
	 */
	UFUNCTION()
	int MemberDefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe the initialized float default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the Speed value
	 */
	UFUNCTION()
	float MemberDefaultSpeed()
	{
		return Speed;
	}

	/**
	 * Observe the zero boundary of the integer member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Health set to 0
	 * @Return the Health value
	 * @Boundary zero value
	 */
	UFUNCTION()
	int MemberHealthZeroBoundary()
	{
		Health = 0;
		return Health;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 1 and the other holds 100
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool MemberHealthIsIndependentAcrossInstances()
	{
		AClassMembersActor Other;
		Health = 1;
		Other.Health = 100;

		if (Health != 1)
		{
			return false;
		}

		return Other.Health == 100;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassMembersActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MemberActorDefaultsToNull()
	{
		AClassMembersActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
