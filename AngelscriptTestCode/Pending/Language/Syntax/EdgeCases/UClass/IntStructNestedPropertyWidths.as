/**
 * @version v1
 * @summary A USTRUCT nested inside an actor, holding all eight int widths with non-trivial defaults that reflection must preserve.
 * @topic Language
 */
/**
 * @version root
 * @summary A USTRUCT nested inside an actor, holding all eight int widths with non-trivial defaults that reflection must preserve.
 * @topic Baseline
 */
/**
 * The nested struct holding every int width.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared struct with eight defaulted widths
 */
USTRUCT()
struct FCoverageIntNestedWidths
{
	UPROPERTY()
	int8 Int8Value = -12;

	UPROPERTY()
	int16 Int16Value = -1234;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = -9000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UIntValue = 3000000000;

	UPROPERTY()
	uint64 UInt64Value = 12000000000000000000;
}

UCLASS()
class ACoverageIntStructNestedWidthsActor : AActor
{
	UPROPERTY()
	FCoverageIntNestedWidths Stats;

	/**
	 * Observe that all eight nested defaults are readable without BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight nested defaults match
	 */
	UFUNCTION()
	bool IntStructNestedWidthsNominal()
	{
		if (Stats.Int8Value != -12)
		{
			return false;
		}

		if (Stats.Int16Value != -1234)
		{
			return false;
		}

		if (Stats.IntValue != 123456)
		{
			return false;
		}

		if (Stats.Int64Value != -9000000000)
		{
			return false;
		}

		if (Stats.UInt8Value != 250)
		{
			return false;
		}

		if (Stats.UInt16Value != 60000)
		{
			return false;
		}

		if (Stats.UIntValue != 3000000000)
		{
			return false;
		}

		return Stats.UInt64Value == 12000000000000000000;
	}

	/**
	 * Observe that mutating a copy leaves the nested original intact.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copy of the Stats struct
	 * @Return true when the original keeps 123456 and the copy holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntStructNestedWidthsCopyIndependence()
	{
		FCoverageIntNestedWidths Copy = Stats;
		Copy.IntValue = 0;

		if (Stats.IntValue != 123456)
		{
			return false;
		}

		return Copy.IntValue == 0;
	}
}
/** @end */
