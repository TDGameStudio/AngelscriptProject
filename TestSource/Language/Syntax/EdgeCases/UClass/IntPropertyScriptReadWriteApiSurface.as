/**
 * The script-facing read/write API surface for int-family UPROPERTYs: a reader
 * that sums all eight widths and a rewriter that replaces every value in place
 * then sums again.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntPropertyScriptReadWriteApiSurface
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntPropertyScriptReadWriteApiSurface
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntPropertyScriptReadWriteApiSurface
 * @Provenance sha256=fd4267603cebc992e21bb61ccd69b680a5a91e0990de19852cd7acba589acdd2; lines 1489-1538.
 * @Provenance Oracle: ReadCurrentSum()==16; RewriteAndReadCurrentSum()==0 then Int8Value -8 ... UInt64Value 64.
 * @Provenance Extra: local construct is the default sum 16 without rewrite.
 * @Provenance FixtureIsolated. Actor owns the integers; RewriteAndReadCurrentSum mutates in place.
 */

UCLASS()
class ACoverageIntScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	int8 Int8Value = -1;

	UPROPERTY()
	int16 Int16Value = -2;

	UPROPERTY()
	int IntValue = -3;

	UPROPERTY()
	int64 Int64Value = -4;

	UPROPERTY()
	uint8 UInt8Value = 5;

	UPROPERTY()
	uint16 UInt16Value = 6;

	UPROPERTY()
	uint UIntValue = 7;

	UPROPERTY()
	uint64 UInt64Value = 8;

	/**
	 * Sums all eight widths as int.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs all eight UPROPERTYs
	 * @Return the widened sum of every value
	 */
	UFUNCTION()
	int ReadCurrentSum()
	{
		return int(Int8Value) + int(Int16Value) + IntValue + int(Int64Value)
			+ int(UInt8Value) + int(UInt16Value) + int(UIntValue) + int(UInt64Value);
	}

	/**
	 * Rewrites every width in place and returns the new sum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 0 once the eight new values cancel out
	 */
	UFUNCTION()
	int RewriteAndReadCurrentSum()
	{
		Int8Value = -8;
		Int16Value = -16;
		IntValue = -32;
		Int64Value = -64;
		UInt8Value = 8;
		UInt16Value = 16;
		UIntValue = 32;
		UInt64Value = 64;
		return ReadCurrentSum();
	}

	/**
	 * Observe the default sum without any rewrite.
	 *
	 * @Kind Observe
	 * @Inputs a freshly constructed actor
	 * @Return 16
	 * @Boundary default values
	 */
	UFUNCTION()
	int IntPropertyScriptApiDefaultSum()
	{
		return ReadCurrentSum();
	}

	/**
	 * Observe the rewritten state.
	 *
	 * @Kind Observe
	 * @Inputs RewriteAndReadCurrentSum() then the sampled properties
	 * @Return true when the sum is 0 and both sampled ends hold their new values
	 */
	UFUNCTION()
	bool IntPropertyScriptApiRewrite()
	{
		int After = RewriteAndReadCurrentSum();

		if (After != 0)
		{
			return false;
		}

		if (Int8Value != -8)
		{
			return false;
		}

		return UInt64Value == 64;
	}
}
