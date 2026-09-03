/**
 * Conversions between FString, FName, and FText, plus numeric formatting into
 * text. An FString builds an FName, an FName formats back to an FString, and
 * an FText is built from a string and read back the same way. An empty string
 * produces the None name rather than failing.
 *
 * @Theme Language.Casting
 * @Subject Casting.StringNameText
 * @Harness Function
 * @Tag Language.Casting.StringNameTextConversions
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::StringConversions
 * @Provenance Oracle: StringToName Convert; NameToString MyName; TextToString TextValue;
 * @Provenance StringToTextToString FromString; IntToString 123; FloatToString 2.5.
 * @Provenance Extra: empty FString gives the None FName; FromInt(0) is "0".
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace CastingTest
{
	/**
	 * Observe that an FString builds an FName carrying the same text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FName("Convert")
	 * @Return the name built from the string
	 */
	UFUNCTION()
	FName StringConvertsToName()
	{
		FString s = "Convert";
		return FName(s);
	}

	/**
	 * Observe that an FName formats back to its text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs n"MyName".ToString()
	 * @Return "MyName"
	 */
	UFUNCTION()
	FString NameConvertsToString()
	{
		FName n = n"MyName";
		return n.ToString();
	}

	/**
	 * Observe that an FText built from a literal reads back its text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FText::FromString("TextValue").ToString()
	 * @Return "TextValue"
	 */
	UFUNCTION()
	FString TextConvertsToString()
	{
		FText t = FText::FromString("TextValue");
		return t.ToString();
	}

	/**
	 * Observe the string to text and back round trip.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FText::FromString("FromString").ToString()
	 * @Return "FromString"
	 */
	UFUNCTION()
	FString StringRoundTripsThroughText()
	{
		FString s = "FromString";
		FText t = FText::FromString(s);
		return t.ToString();
	}

	/**
	 * Observe that an int formats to its decimal text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(123)
	 * @Return "123"
	 */
	UFUNCTION()
	FString IntFormatsToString()
	{
		int x = 123;
		return FString::FromInt(x);
	}

	/**
	 * Observe that a float formats to its decimal text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::SanitizeFloat(2.5)
	 * @Return "2.5"
	 */
	UFUNCTION()
	FString FloatFormatsToString()
	{
		return FString::SanitizeFloat(2.5);
	}

	/**
	 * Observe the empty default: an empty string produces the None name.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FName("")
	 * @Return true when the name reports IsNone
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool EmptyStringConvertsToNoneName()
	{
		FString Empty;
		FName NoneName = FName(Empty);
		return NoneName.IsNone();
	}

	/**
	 * Observe the zero boundary: FromInt(0) formats to "0".
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(0)
	 * @Return "0"
	 * @Boundary zero
	 */
	UFUNCTION()
	FString IntZeroFormatsToString()
	{
		return FString::FromInt(0);
	}
}
