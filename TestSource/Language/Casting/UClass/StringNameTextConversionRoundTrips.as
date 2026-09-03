/**
 * The same FString, FName, and FText round trips as
 * ../Function/StringNameTextConversions, but carried on an actor so C++ can
 * read the results off UPROPERTYs by path after BeginPlay runs. The name and
 * text round trips each go out to the other type and back, and a number
 * round-trips through text in both the positive and negative direction.
 * The UPROPERTY names are read by path from C++ and must not be renamed:
 * StringFromName, StringFromText, StringFromInt, NameFromString,
 * TextFromString, NameRoundTrip, TextRoundTrip, NumericStringRoundTrip.
 *
 * @Theme Language.Casting
 * @Subject Casting.StringNameTextRoundTripOnActor
 * @Harness UClass
 * @Tag Language.Casting.StringNameTextConversionRoundTrips
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptCoverageTypeConversionTests.cpp::StringNameTextConversionRoundTrips
 * @Provenance Oracle: NameFromString CoverageName; StringFromName CoverageName; TextFromString CoverageText;
 * @Provenance StringFromText CoverageText; StringFromInt 314; NameRoundTrip/TextRoundTrip/NumericStringRoundTrip true.
 * @Provenance Extra: empty FString gives the None FName; FromInt(0) is "0".
 * @Provenance FixtureIsolated. Runner owns spawn and BeginPlay.
 */

UCLASS()
class ACoverageStringNameTextActor : AActor
{
	UPROPERTY()
	FString StringFromName;

	UPROPERTY()
	FString StringFromText;

	UPROPERTY()
	FString StringFromInt;

	UPROPERTY()
	FName NameFromString;

	UPROPERTY()
	FText TextFromString;

	UPROPERTY()
	bool NameRoundTrip = false;

	UPROPERTY()
	bool TextRoundTrip = false;

	UPROPERTY()
	bool NumericStringRoundTrip = false;

	/**
	 * Runs the round trips once at play time, so the C++ fixture can read the
	 * resulting property values by path.
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FString Source = "CoverageName";
		NameFromString = FName(Source);
		StringFromName = NameFromString.ToString();

		TextFromString = FText::FromString("CoverageText");
		StringFromText = TextFromString.ToString();

		StringFromInt = FString::FromInt(314);
		NumericStringRoundTrip = StringFromInt == "314" && FString::FromInt(-12) == "-12";
		NameRoundTrip = StringFromName == Source && NameFromString == n"CoverageName";
		TextRoundTrip = StringFromText == "CoverageText";
	}
}

namespace CastingTest
{
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
	bool EmptyStringGivesNoneName()
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
	FString FromIntZeroFormatsToString()
	{
		return FString::FromInt(0);
	}
}
