/**
 * @version v1
 * @summary Near-boundary values one step above each signed minimum: min+1 for each width, written through a script helper rather than reflection.
 * @topic Language
 */
/**
 * @version root
 * @summary Near-boundary values one step above each signed minimum: min+1 for each width, written through a script helper rather than reflection.
 * @topic Baseline
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
/** @end */
