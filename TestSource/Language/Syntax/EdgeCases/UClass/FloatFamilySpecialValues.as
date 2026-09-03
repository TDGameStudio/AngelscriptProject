/**
 * NaN and infinity handling on float and double UPROPERTYs. The C++ runner writes
 * each special through SetByPath and reads it back through VerifyByPath; the
 * observers confirm the defaults are finite before any write.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatFamilySpecialValues
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatFamilySpecialValues
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilySpecialValues
 * @Provenance sha256=6afeac2d80156a3ffa7f6edd9881c69d11ddb2b24b3d3b62573db0ed0868b319; lines 449-459.
 * @Provenance Oracle: FloatValue NaN then +Inf then -Inf; DoubleValue follows the same specials.
 * @Provenance Extra: default 0 is finite. FixtureIsolated. NaN is not compared with ==.
 */

UCLASS()
class ACoverageFloatSpecialActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties start finite and zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are finite, zero and not NaN
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatSpecialDefaultFiniteEmpty()
	{
		if (!Math::IsFinite(FloatValue))
		{
			return false;
		}

		if (!Math::IsFinite(DoubleValue))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DoubleValue, 0.0))
		{
			return false;
		}

		if (Math::IsNaN(FloatValue))
		{
			return false;
		}

		return !Math::IsNaN(DoubleValue);
	}
}
