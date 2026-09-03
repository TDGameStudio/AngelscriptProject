/**
 * A class deriving from a final actor. C++ originally expected this to be
 * rejected, but the live C++ wraps it in #if 0 because structural validation is
 * absent: the child compiles. The observers prove the child is a usable type.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.InheritFromFinalActor
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.InheritFromFinalActor
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 9 is #if 0
 * @Provenance (structural-validation-absent); AChildInheritActor : AFinalInheritActor compiles.
 * @Provenance sha256=74a3ccf165abb20eee4875e6e54300d3fe299a7b00f54aa1040a9a1d2983c6d5; lines 193-196.
 * @Provenance Oracle: child of a final actor is a usable type; default child handle is null.
 * @Provenance Extra: assigning aliases the same child handle. FixtureIsolated value oracle.
 */

class AFinalInheritActor : AActor final
{
}

class AChildInheritActor : AFinalInheritActor
{
	/**
	 * Observe that the child of the final class is still that class.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AChildInheritActor handle
	 * @Return 1 when the value is an AFinalInheritActor, otherwise 0
	 */
	UFUNCTION()
	int FinalChildIsFinalActor()
	{
		AChildInheritActor Child;
		if (Child is AFinalInheritActor)
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
	 * @Inputs an unset AChildInheritActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalChildDefaultsToNull()
	{
		AChildInheritActor Child;
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
	bool FinalChildAssignAliases()
	{
		AChildInheritActor First;
		AChildInheritActor Second;
		First = Second;
		return First is Second;
	}
}
