/**
 * A valueless default statement currently compiles: C++ wraps the
 * AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent).
 * X stays at its inline 0. Keep X.
 *
 * @Theme Feature.Default
 * @Subject Default.WithoutValue
 * @Harness UClass
 * @Tag Feature.Default.DefaultWithoutValue
 * @Provenance Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior: structural-validation-absent) so a valueless default currently compiles.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative ASSyntaxDS_AttrNoValue.
 * @Provenance Oracle: X stays 0. Extra: empty handle is null; write 1 then restore. Keep X.
 * @Provenance FixtureIsolated.
 */

class AAttrNoValActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrNoValActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that X stays at the inline zero.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 */
	UFUNCTION()
	int XStaysZero()
	{
		return X;
	}

	/**
	 * Observe that a write of 1 lands and can be restored.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs X written to 1 then restored
	 * @Return 1, the value after the write
	 * @Boundary write then restore
	 */
	UFUNCTION()
	int WriteBoundary()
	{
		int Saved = X;
		X = 1;
		int After = X;
		X = Saved;
		return After;
	}
}
