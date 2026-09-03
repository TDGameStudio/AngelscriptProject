/**
 * Near-boundary values one step above each signed minimum: min+1 for each width,
 * written through a script helper rather than reflection.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyNearBoundaryValues
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntFamilyNearBoundaryValues
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyNearBoundaryValues
 * @Provenance sha256=f16d8d1f1d4bbc62060b86d5630b39be66764b0bf3aaca11bffa07514a176e87; lines 438-466.
 * @Provenance Oracle: Int8Value min+1; Int16Value min+1; IntValue min+1; Int64Value min+1 via SetByPath.
 * @Provenance Extra: local construct is empty 0; script WriteNearMins uses -127/-32767/-2147483647.
 * @Provenance FixtureIsolated. Actor owns the reflected integers.
 */

UCLASS()
class ACoverageIntNearBoundaryActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	/**
	 * Writes each signed width's minimum plus one.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their near-minima
	 */
	UFUNCTION()
	void WriteNearMins()
	{
		Int8Value = -127;
		Int16Value = -32767;
		IntValue = -2147483647;
		Int64Value = -9223372036854775807;
	}

	/**
	 * Observe that a locally constructed actor holds zeros.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the sampled properties are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyNearBoundaryDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		if (IntValue != 0)
		{
			return false;
		}

		return UInt8Value == 0;
	}

	/**
	 * Observe that the near-minima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteNearMins() then the signed properties
	 * @Return true when all three lower widths hold min+1
	 * @Boundary near-minima
	 */
	UFUNCTION()
	bool IntFamilyNearBoundaryNominal()
	{
		WriteNearMins();

		if (Int8Value != -127)
		{
			return false;
		}

		if (Int16Value != -32767)
		{
			return false;
		}

		return IntValue == -2147483647;
	}
}
