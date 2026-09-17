/**
 * @version v1
 * @summary A write-and-read round trip across all eight int widths, with mixed signs and magnitudes, driven by a script helper.
 * @topic Language
 */
/**
 * @version root
 * @summary A write-and-read round trip across all eight int widths, with mixed signs and magnitudes, driven by a script helper.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntRoundTripActor : AActor
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
	 * Writes every width's round-trip value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all eight UPROPERTYs hold their round-trip values
	 */
	UFUNCTION()
	void WriteRoundTripValues()
	{
		Int8Value = -42;
		Int16Value = -12345;
		IntValue = -987654;
		Int64Value = -9000000000;
		UInt8Value = 200;
		UInt16Value = 54321;
		UInt32Value = 3000000000;
		UInt64Value = 12000000000000000000;
	}

	/**
	 * Observe that a locally constructed actor holds the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight fields read 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyWriteRoundTripDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		if (Int16Value != 0)
		{
			return false;
		}

		if (IntValue != 0)
		{
			return false;
		}

		if (Int64Value != 0)
		{
			return false;
		}

		if (UInt8Value != 0)
		{
			return false;
		}

		if (UInt16Value != 0)
		{
			return false;
		}

		if (UInt32Value != 0)
		{
			return false;
		}

		return UInt64Value == 0;
	}

	/**
	 * Observe the values after the write round trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteRoundTripValues() then all eight fields
	 * @Return true when all eight values match
	 */
	UFUNCTION()
	bool IntFamilyWriteRoundTripNominal()
	{
		WriteRoundTripValues();

		if (Int8Value != -42)
		{
			return false;
		}

		if (Int16Value != -12345)
		{
			return false;
		}

		if (IntValue != -987654)
		{
			return false;
		}

		if (Int64Value != -9000000000)
		{
			return false;
		}

		if (UInt8Value != 200)
		{
			return false;
		}

		if (UInt16Value != 54321)
		{
			return false;
		}

		if (UInt32Value != 3000000000)
		{
			return false;
		}

		return UInt64Value == 12000000000000000000;
	}
}
/** @end */
