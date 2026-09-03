/**
 * Numeric widening, explicit casts, enum conversion, and FString formatting
 * in one subject. A uint8 widens to an int implicitly; an explicit cast
 * converts between int and float, truncating on the way back; an enum
 * converts both to an int and back from one, with the zero enumerator
 * reported as 0; and an int formats to text and round-trips through both
 * FromInt and SanitizeFloat.
 *
 * @Theme Language.Casting
 * @Subject Casting.NumericEnumAndString
 * @Harness Function
 * @Tag Language.Casting.NumericEnumAndStringConversions
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptCoverageTypeConversionTests.cpp::NumericEnumAndStringConversions
 * @Provenance Oracle: ImplicitWidening 250; ExplicitIntToFloat 42; ExplicitFloatToInt 9; EnumToInt 3;
 * @Provenance IntToEnumComparison true; IntToString "42"; IntStringRoundTrip true; FloatStringRoundTrip true.
 * @Provenance Extra: uint8 0 widens to 0; enum None is 0; FromInt(0) is "0".
 * @Provenance DefaultSafe. Source owns locals.
 */

enum ECoverageConversionState
{
	None = 0,
	Ready = 3
}

namespace CastingTest
{
	/**
	 * Observe implicit widening: a uint8 at the top of its range widens to an
	 * int without loss.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign uint8 250 to an int
	 * @Return 250 when the value is preserved
	 */
	UFUNCTION()
	int Uint8WidensToInt()
	{
		uint8 Small = 250;
		int Wider = Small;
		return Wider;
	}

	/**
	 * Observe an explicit int-to-float cast.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs float(42)
	 * @Return 42.0 when the value is preserved
	 */
	UFUNCTION()
	float ExplicitCastIntToFloat()
	{
		int Value = 42;
		return float(Value);
	}

	/**
	 * Observe an explicit float-to-int cast, which truncates the fraction.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(9.75f)
	 * @Return 9 when the fraction is discarded
	 */
	UFUNCTION()
	int ExplicitCastFloatToInt()
	{
		float Value = 9.75f;
		return int(Value);
	}

	/**
	 * Observe that an enum converts to its underlying integer value.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(ECoverageConversionState::Ready)
	 * @Return 3 when the enumerator carries that value
	 */
	UFUNCTION()
	int EnumConvertsToInt()
	{
		return int(ECoverageConversionState::Ready);
	}

	/**
	 * Observe that an integer converts back to the matching enumerator.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs ECoverageConversionState(3) compared against Ready
	 * @Return true when the conversion produces the same enumerator
	 */
	UFUNCTION()
	bool IntConvertsBackToEnum()
	{
		ECoverageConversionState State = ECoverageConversionState(3);
		return State == ECoverageConversionState::Ready;
	}

	/**
	 * Observe that an int formats to its decimal text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(42)
	 * @Return "42"
	 */
	UFUNCTION()
	FString IntFormatsToString()
	{
		return FString::FromInt(42);
	}

	/**
	 * Observe that an int round-trips through text, both positive and negative.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(123) and FString::FromInt(-456)
	 * @Return true when both format to the expected text
	 */
	UFUNCTION()
	bool IntRoundTripsThroughString()
	{
		if (FString::FromInt(123) != "123")
		{
			return false;
		}
		return FString::FromInt(-456) == "-456";
	}

	/**
	 * Observe that a float formats to text beginning with its decimal form.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::SanitizeFloat(12.5)
	 * @Return true when the text starts with "12.5"
	 */
	UFUNCTION()
	bool FloatRoundTripsThroughString()
	{
		FString Value = FString::SanitizeFloat(12.5);
		return Value.StartsWith("12.5");
	}

	/**
	 * Observe the zero default of the widening conversion.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign uint8 0 to an int
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int Uint8WidensZeroDefault()
	{
		uint8 Small = 0;
		int Wider = Small;
		return Wider;
	}

	/**
	 * Observe the None enumerator boundary: the zero enumerator converts to 0.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(ECoverageConversionState::None)
	 * @Return 0
	 * @Boundary zero enumerator
	 */
	UFUNCTION()
	int EnumNoneConvertsToZero()
	{
		return int(ECoverageConversionState::None);
	}
}
