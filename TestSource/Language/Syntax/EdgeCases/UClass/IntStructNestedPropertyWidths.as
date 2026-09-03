/**
 * A USTRUCT nested inside an actor, holding all eight int widths with
 * non-trivial defaults that reflection must preserve.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntStructNestedPropertyWidths
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntStructNestedPropertyWidths
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntStructNestedPropertyWidths
 * @Provenance sha256=492fad1780fecd6a0bb3f67d4080077b90b358720a1990eadf61e5ffd7034c96; lines 1284-1319.
 * @Provenance Oracle: Stats reflects as FStructProperty with int8/int16/int/int64/uint8/uint16/uint/uint64 members;
 * @Provenance defaults Int8Value -12; Int16Value -1234; IntValue 123456; Int64Value -9000000000;
 * @Provenance UInt8Value 250; UInt16Value 60000; UIntValue 3000000000; UInt64Value 12000000000000000000.
 * @Provenance Extra: local construct reads those USTRUCT defaults (empty actor, no BeginPlay).
 * @Provenance FixtureIsolated. Struct owns the nested integers.
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
