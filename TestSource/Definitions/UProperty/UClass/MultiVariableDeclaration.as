/**
 * A multi-variable UPROPERTY currently compiles because C++ wraps the failure
 * in #if 0 (structural-validation-absent). The observers cover X and Y defaulting
 * to 0 and that a Y write is independent of X.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.MultiVariableDeclaration
 * @Harness UClass
 * @Tag Definitions.UProperty.MultiVariableDeclaration
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so a multi-variable
 * @Provenance UPROPERTY currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
 * @Provenance UPropTN_MultiDecl; lines 532-538;
 * @Provenance sha256=042c51edfd8e5c9a86e0ea53b460d5a6d39ba402c0a5506c39ffbb1584361a26.
 * @Provenance Oracle: X and Y default to 0. Extra: 0 empty/default; Y write is independent of X.
 * @Provenance FixtureIsolated.
 */

class AUPropMultiDeclActor : AActor
{
	UPROPERTY()
	int X, Y;

	/**
	 * Observe that X and Y default to 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs none
	 * @Return true when both are 0
	 */
	UFUNCTION()
	bool MultiDeclDefault()
	{
		if (X != 0)
		{
			return false;
		}
		return Y == 0;
	}

	/**
	 * Observe that the empty defaults are 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs none
	 * @Return true when both are 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool MultiDeclEmptyDefault()
	{
		if (X != 0)
		{
			return false;
		}
		return Y == 0;
	}

	/**
	 * Observe that writing Y leaves X unchanged.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultiVariableDeclaration
	 * @Inputs Y written to 7 then restored
	 * @Return true when X stays 0 and Y becomes 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MultiDeclCopyIndependence()
	{
		int SavedX = X;
		Y = 7;
		if (X != SavedX)
		{
			Y = 0;
			return false;
		}
		if (Y != 7)
		{
			Y = 0;
			return false;
		}
		Y = 0;
		return SavedX == 0;
	}
}
