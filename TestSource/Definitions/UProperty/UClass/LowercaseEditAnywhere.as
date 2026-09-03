/**
 * Lowercase editanywhere currently compiles because C++ wraps the failure in
 * #if 0 (structural-validation-absent). The observers cover the default 0 and a
 * boundary write that restores 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.LowercaseEditAnywhere
 * @Harness UClass
 * @Tag Definitions.UProperty.LowercaseEditAnywhere
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so lowercase
 * @Provenance editanywhere currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
 * @Provenance UPropSN_CaseSensitive; lines 298-304;
 * @Provenance sha256=04ed128f739c3e8778bbdc2856630299e3074344e028c68a02332b82c3731617.
 * @Provenance Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
 * @Provenance FixtureIsolated.
 */

class AUPropCaseActor : AActor
{
	UPROPERTY(editanywhere)
	int X = 0;

	/**
	 * Observe the default X of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.LowercaseEditAnywhere
	 * @Inputs none
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool CaseDefault()
	{
		return X == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.LowercaseEditAnywhere
	 * @Inputs none
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool CaseEmptyDefault()
	{
		return X == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores the default 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.LowercaseEditAnywhere
	 * @Inputs X written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool CaseBoundaryWrite()
	{
		int Saved = X;
		X = 1;
		bool bWrote = X == 1;
		X = Saved;
		if (!bWrote)
		{
			return false;
		}
		return Saved == 0;
	}
}
