/**
 * BlueprintReadOnly plus BlueprintReadWrite currently compiles because C++ wraps
 * the failure in #if 0 (structural-validation-absent). The observers cover the
 * default 0 and a boundary write that restores 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ConflictReadOnlyReadWrite
 * @Harness UClass
 * @Tag Definitions.UProperty.ConflictReadOnlyReadWrite
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so BlueprintReadOnly
 * @Provenance plus BlueprintReadWrite currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
 * @Provenance UPropSN_ConflictRORW; lines 206-212;
 * @Provenance sha256=2b097e9a2cd83ba797869c32ba8e25c4281fcd5da7e78f114944e108f95babfd.
 * @Provenance Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
 * @Provenance FixtureIsolated.
 */

class AUPropConflictRWActor : AActor
{
	UPROPERTY(BlueprintReadOnly, BlueprintReadWrite)
	int X = 0;

	/**
	 * Observe the default X of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConflictReadOnlyReadWrite
	 * @Inputs none
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool ConflictRWDefault()
	{
		return X == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConflictReadOnlyReadWrite
	 * @Inputs none
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool ConflictRWEmptyDefault()
	{
		return X == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores the default 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConflictReadOnlyReadWrite
	 * @Inputs X written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool ConflictRWBoundaryWrite()
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
