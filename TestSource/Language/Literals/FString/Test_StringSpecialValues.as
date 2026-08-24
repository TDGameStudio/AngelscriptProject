// Theme: Language.Literals.FString. WorldStory: empty, long, escaped, unicode, NAME_None.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringSpecialValues
// sha256=9c7d8b4ae64291a7717699cf0498dd4ae0adcca320799be1a6a05c9c2bf0e077; lines 838-885.
// Oracle: EmptyString ""; LongString 1024 x's; SpecialChars newline/tab/quote/backslash;
// UnicodeString "Hello 世界 🌍"; EmptyName NAME_None; SpecialName "Name.With.Dots-123";
// EmptyText empty; UnicodeText "Text 世界".
// Extra: defaults before BeginPlay are empty; LongString length is the 1024 boundary.
// FixtureIsolated. Keep UPROPERTY names used by VerifyByPath.

UCLASS()
class ACoverageFStringSpecialActor : AActor
{
	UPROPERTY()
	FString EmptyString;

	UPROPERTY()
	FString LongString;

	UPROPERTY()
	FString SpecialChars;

	UPROPERTY()
	FString UnicodeString;

	UPROPERTY()
	FName EmptyName;

	UPROPERTY()
	FName SpecialName;

	UPROPERTY()
	FText EmptyText;

	UPROPERTY()
	FText UnicodeText;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EmptyString = "";

		for (int i = 0; i < 1024; ++i)
		{
			LongString += "x";
		}

		SpecialChars = "Hello\nWorld\tTab\"Quote\"\\Backslash";

		UnicodeString = "Hello 世界 🌍";
		EmptyName = NAME_None;
		SpecialName = FName("Name.With.Dots-123");
		EmptyText = FText::FromString("");
		UnicodeText = FText::FromString("Text 世界");
	}

	UFUNCTION()
	bool Observe_EmptyAndLongBoundary()
	{
		return EmptyString.Len() == 0 && LongString.Len() == 1024 && EmptyName == NAME_None && EmptyText.IsEmpty();
	}
}
