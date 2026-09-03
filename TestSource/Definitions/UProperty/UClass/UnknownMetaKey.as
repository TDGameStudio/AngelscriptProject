/**
 * An unknown Meta key currently compiles because C++ wraps the failure in #if 0
 * (structural-validation-absent). The observers cover the default 0 and a
 * boundary write that restores 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UnknownMetaKey
 * @Harness UClass
 * @Tag Definitions.UProperty.UnknownMetaKey
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so an unknown Meta key
 * @Provenance currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
 * @Provenance UPropSN_BadMetaKey; lines 321-327;
 * @Provenance sha256=95ebe6befde4a08cb7672c9a04b5682f2fa4a1410a48c94837df48e9fcee09c2.
 * @Provenance Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
 * @Provenance FixtureIsolated.
 */

class AUPropBadMetaActor : AActor
{
	UPROPERTY(Meta = (NonExistentMetaKey = true))
	int X = 0;

	/**
	 * Observe the default X of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs none
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool BadMetaDefault()
	{
		return X == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs none
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool BadMetaEmptyDefault()
	{
		return X == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores the default 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UnknownMetaKey
	 * @Inputs X written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool BadMetaBoundaryWrite()
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
