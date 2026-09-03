/**
 * A script-level constructor that assigns a member. The constructor must run at
 * construction time, so the member is neither left at zero nor clobbered by a
 * later write.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ScriptConstructorAssignsMember
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.ScriptConstructorAssignsMember
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 6 AssertCompiles.
 * @Provenance sha256=327bee221f36e8f25f77b5257d9b7d865242894e8d0bd0a1d17beac53ae5cc8f; lines 94-100.
 * @Provenance Oracle: AClassCtorActor() sets X to 10.
 * @Provenance Extra: X is not left at 0 after construction; a later write is independent of
 * @Provenance the ctor store. FixtureIsolated.
 */

class AClassCtorActor : AActor
{
	int X;

	/**
	 * Initializes the member at construction time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return a new AClassCtorActor with X set to 10
	 */
	AClassCtorActor()
	{
		X = 10;
	}

	/**
	 * Observe the value the constructor stored.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value
	 */
	UFUNCTION()
	int ConstructorStoredValue()
	{
		return X;
	}

	/**
	 * Observe that the member was not left at the zero default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value, or 0 if it is still zero
	 * @Boundary non-zero after construction
	 */
	UFUNCTION()
	int ConstructorNotLeftAtZero()
	{
		if (X == 0)
		{
			return 0;
		}
		return X;
	}

	/**
	 * Observe that a later write replaces the constructed value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs X set to 1 after construction
	 * @Return the X value
	 * @Boundary post-construction write
	 */
	UFUNCTION()
	int ConstructorWriteAfterConstruct()
	{
		X = 1;
		return X;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassCtorActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int ConstructorActorDefaultsToNull()
	{
		AClassCtorActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
