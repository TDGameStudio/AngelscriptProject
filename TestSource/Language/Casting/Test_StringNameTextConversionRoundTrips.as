// Theme: Language.Casting. WorldStory FString/FName/FText and FromInt round-trips on an actor.
// C++: AngelscriptCoverageTypeConversionTests.cpp::StringNameTextConversionRoundTrips
// Oracle: NameFromString CoverageName; StringFromName CoverageName; TextFromString CoverageText;
// StringFromText CoverageText; StringFromInt 314; NameRoundTrip/TextRoundTrip/NumericStringRoundTrip true.
// Extra: empty FString -> None FName; FromInt(0) is "0". Keep VerifyByPath UPROPERTY names.
// FixtureIsolated. Runner owns spawn and BeginPlay.

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

bool Observe_NameFromEmptyDefault()
{
	FString Empty;
	FName NoneName = FName(Empty);
	return NoneName.IsNone();
}

FString Observe_FromInt_ZeroBoundary()
{
	return FString::FromInt(0);
}
