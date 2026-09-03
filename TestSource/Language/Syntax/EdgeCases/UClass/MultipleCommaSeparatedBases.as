/**
 * A class declaring two comma-separated base classes. C++ originally expected
 * multi-base inheritance to be rejected, but the live C++ wraps this in #if 0
 * because structural validation is absent: the class compiles. The observers
 * prove the class is a usable AActor type.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.MultipleCommaSeparatedBases
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.MultipleCommaSeparatedBases
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 8 is #if 0
 * @Provenance (structural-validation-absent); AActor, APawn comma bases compile.
 * @Provenance sha256=c77f9737749d79f563c0f348c0b0307f066652309f903afe285c980f09c83227; lines 184-186.
 * @Provenance Oracle: AClassMultiBaseActor is declared; default handle is null.
 * @Provenance Extra: assigning aliases the same handle. FixtureIsolated value oracle.
 */

class AClassMultiBaseActor : AActor, APawn
{
	/**
	 * Observe that the multi-base class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassMultiBaseActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int MultiBaseActorIsAnActor()
	{
		AClassMultiBaseActor Actor;
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
	 * @Inputs an unset AClassMultiBaseActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MultiBaseActorDefaultsToNull()
	{
		AClassMultiBaseActor Unset;
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
	bool MultiBaseActorAssignAliases()
	{
		AClassMultiBaseActor First;
		AClassMultiBaseActor Second;
		First = Second;
		return First is Second;
	}
}
