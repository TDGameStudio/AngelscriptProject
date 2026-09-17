/**
 * @version v1
 * @summary The int family's UPROPERTY declaration defaults across all eight widths, read from the CDO without running BeginPlay.
 * @topic Language
 */
/**
 * @version root
 * @summary The int family's UPROPERTY declaration defaults across all eight widths, read from the CDO without running BeginPlay.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntDefaultsActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 100;

	UPROPERTY()
	int16 Int16Value = 30000;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = 10000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UInt32Value = 123456;

	UPROPERTY()
	uint64 UInt64Value = 123456;

	/**
	 * Observe that all eight declaration defaults are readable without BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight widths hold their declared defaults
	 */
	UFUNCTION()
	bool IntFamilyDeclarationDefaultsNominal()
	{
		if (Int8Value != 100)
		{
			return false;
		}

		if (Int16Value != 30000)
		{
			return false;
		}

		if (IntValue != 123456)
		{
			return false;
		}

		if (Int64Value != 10000000000)
		{
			return false;
		}

		if (UInt8Value != 250)
		{
			return false;
		}

		if (UInt16Value != 60000)
		{
			return false;
		}

		if (UInt32Value != 123456)
		{
			return false;
		}

		return UInt64Value == 123456;
	}
}
/** @end */
