/**
 * An Abstract UCLASS paired with a concrete child. The abstract type is declared
 * but not instantiated; the child carries a member that starts at zero and
 * accepts writes.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.AbstractUClassWithConcreteChild
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.AbstractUClassWithConcreteChild
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 5 AssertCompiles.
 * @Provenance sha256=c3914ea40925bf350d8ef2f52d785f95c419099fe3199af6f1d5398527445887; lines 87-90.
 * @Provenance Oracle: AMyAbstract is declared Abstract; default handle is null.
 * @Provenance Extra: concrete child EmptyFlag defaults to 0; writing the child does not
 * @Provenance require spawning the abstract type. FixtureIsolated.
 */

UCLASS(Abstract)
class AMyAbstract : AActor
{
}

UCLASS()
class AMyAbstractConcrete : AMyAbstract
{
	int EmptyFlag = 0;

	/**
	 * Observe the child's initialized member default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed child
	 * @Return the EmptyFlag value
	 */
	UFUNCTION()
	int ConcreteChildDefaultFlag()
	{
		return EmptyFlag;
	}

	/**
	 * Observe that a write lands on the child's member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EmptyFlag set to 1
	 * @Return the EmptyFlag value
	 * @Boundary non-zero write
	 */
	UFUNCTION()
	int ConcreteChildFlagWriteBoundary()
	{
		EmptyFlag = 1;
		return EmptyFlag;
	}

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AMyAbstract handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int AbstractHandleDefaultsToNull()
	{
		AMyAbstract Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
