/**
 * Boolean UPROPERTY defaults: an explicit true, an explicit false, and one left
 * without an initializer. The observers confirm the defaults and that writing one
 * actor leaves another untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolDeclarationDefaults
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.BoolDeclarationDefaults
 * @Provenance C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolDeclarationDefaults
 * @Provenance sha256=ce2c84f7a2e593c3ec8ac9853685f9885e64d344cdd12ae107e693c508569640; lines 131-144.
 * @Provenance Oracle after spawn: TrueValue true, FalseValue false, NoDefaultValue false.
 * @Provenance Extra: local construct matches those defaults. FixtureIsolated.
 */

UCLASS()
class ACoverageBoolDefaultsActor : AActor
{
	UPROPERTY()
	bool TrueValue = true;

	UPROPERTY()
	bool FalseValue = false;

	UPROPERTY()
	bool NoDefaultValue;

	/**
	 * Observe that all three declarations hold their defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are true, false and false
	 * @Boundary default values
	 */
	UFUNCTION()
	bool BoolDefaultsHoldDeclaredValues()
	{
		if (TrueValue != true)
		{
			return false;
		}

		if (FalseValue != false)
		{
			return false;
		}

		return NoDefaultValue == false;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds the writes and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BoolDefaultsAreIndependentAcrossInstances()
	{
		ACoverageBoolDefaultsActor Other =
			Cast<ACoverageBoolDefaultsActor>(
				NewObject(GetTransientPackage(), ACoverageBoolDefaultsActor::StaticClass(), n"CoverageBoolDefaultsActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolDeclarationDefaults setup: NewObject returned null");
		}

		TrueValue = false;
		FalseValue = true;
		NoDefaultValue = true;

		if (TrueValue != false)
		{
			return false;
		}

		if (Other.TrueValue != true)
		{
			return false;
		}

		if (Other.FalseValue != false)
		{
			return false;
		}

		return Other.NoDefaultValue == false;
	}
}
