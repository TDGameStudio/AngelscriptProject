/**
 * An actor subclass declared without the A prefix. C++ originally expected the
 * naming convention to be enforced, but the live C++ wraps this in #if 0: the
 * class compiles, so the CSV NegativeDiagnostic is not a compile-fail. The
 * observers prove the class is a usable AActor type.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ActorWithoutPrefixNaming
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.ActorWithoutPrefixNaming
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 7 is #if 0
 * @Provenance (naming-convention-unenforced); class MyActor : AActor compiles.
 * @Provenance sha256=538d503fbfcf4bd1125c258d2c8bb5aef7c1dc78393a4259d55e89c6ffa83a2e; lines 175-177.
 * @Provenance Oracle: MyActor is an AActor subclass; default handle is null.
 * @Provenance Extra: assigning aliases the same handle. FixtureIsolated value oracle.
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
