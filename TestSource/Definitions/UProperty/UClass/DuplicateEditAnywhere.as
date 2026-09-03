/**
 * Duplicate EditAnywhere currently compiles because C++ wraps the failure in
 * #if 0 (structural-validation-absent). The observers cover the default 0 and a
 * boundary write that restores 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.DuplicateEditAnywhere
 * @Harness UClass
 * @Tag Definitions.UProperty.DuplicateEditAnywhere
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so duplicate
 * @Provenance EditAnywhere currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
 * @Provenance UPropSN_DuplicateSpec; lines 251-257;
 * @Provenance sha256=03052e8f650869a5831d2bdefe99088c1e6d313a8f21fb04cc23494eb5881506.
 * @Provenance Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
 * @Provenance FixtureIsolated.
 */

class AUPropDupSpecActor : AActor
{
	UPROPERTY(EditAnywhere, EditAnywhere)
	int X = 0;

	/**
	 * Observe the default X of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.DuplicateEditAnywhere
	 * @Inputs none
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool DupSpecDefault()
	{
		return X == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.DuplicateEditAnywhere
	 * @Inputs none
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool DupSpecEmptyDefault()
	{
		return X == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores the default 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.DuplicateEditAnywhere
	 * @Inputs X written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool DupSpecBoundaryWrite()
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
