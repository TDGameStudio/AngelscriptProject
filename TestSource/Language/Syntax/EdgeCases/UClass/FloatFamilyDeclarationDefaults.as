/**
 * Float and double UPROPERTY defaults: two left uninitialized and two carrying
 * initializers. The observers confirm both groups hold their expected values.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatFamilyDeclarationDefaults
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatFamilyDeclarationDefaults
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyDeclarationDefaults
 * @Provenance sha256=095fa2372c67c7e8b2b1e5c7aaa7b214533407d1ebaf59d139ecc6e0cfdf488f; lines 119-135.
 * @Provenance Oracle on instance and CDO: FloatValue=0.0; DoubleValue=0.0; InitializedFloat=1.25;
 * @Provenance InitializedDouble=2.5. Extra: local construct matches those defaults. FixtureIsolated.
 */

UCLASS()
class ACoverageFloatDefaultsActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	UPROPERTY()
	float InitializedFloat = 1.25f;

	UPROPERTY()
	double InitializedDouble = 2.5;

	/**
	 * Observe that the uninitialized properties read as zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both uninitialised values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatDefaultsUninitializedZero()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that the initialized properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.25 and 2.5
	 * @Boundary initialized values
	 */
	UFUNCTION()
	bool FloatDefaultsInitializedBoundary()
	{
		if (!Math::IsNearlyEqual(InitializedFloat, 1.25))
		{
			return false;
		}

		return Math::IsNearlyEqual(InitializedDouble, 2.5);
	}
}
