/**
 * Duplicate default assignments currently compile: C++ wraps the
 * AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent).
 * The last default wins, so X is 10. Keep X. Instances stay independent.
 *
 * @Theme Feature.Default
 * @Subject Default.DuplicateDefault
 * @Harness UClass
 * @Tag Feature.Default.DuplicateDefault
 * @Provenance Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior: structural-validation-absent) so duplicate default assignments compile.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative ASSyntaxDS_AttrDuplicate.
 * @Provenance Oracle: last default wins, X==10. Extra: empty handle is null; copy independence. Keep X.
 * @Provenance FixtureIsolated.
 */

class AAttrDupActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X = 5;
	default X = 10;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.DuplicateDefault
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrDupActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the last default assignment wins.
	 *
	 * @Kind Observe
	 * @Covers Default.DuplicateDefault
	 * @Inputs a freshly constructed actor
	 * @Return 10
	 */
	UFUNCTION()
	int LastDefaultWins()
	{
		return X;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.DuplicateDefault
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds 10
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrDupActor Second)
	{
		if (Second == nullptr)
		{
			throw("DuplicateDefault setup: required Second is null");
		}
		X = 0;
		return Second.X == 10;
	}
}
