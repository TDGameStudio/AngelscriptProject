// Theme: Language.Literals.FString. WorldStory: escaped FText and a 1050-char FString source.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyScriptSpecialTextValues
// sha256=dd5e254d8c2647b5c31f7f5bf3bd6365bd8429b7232e70361c474945408fbd02; lines 951-977.
// Oracle: EscapedText ToString preserves LineOne/newline/LineTwo/tab/"Quote"/backslash;
// LongTextSource and LongText are 1050 t characters.
// Extra: LongTextSource default empty before BeginPlay.
// FixtureIsolated. Keep UPROPERTY names EscapedText, LongText, LongTextSource.

UCLASS()
class ACoverageFStringSpecialTextActor : AActor
{
	UPROPERTY()
	FText EscapedText;

	UPROPERTY()
	FText LongText;

	UPROPERTY()
	FString LongTextSource;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EscapedText = FText::FromString("LineOne\nLineTwo\t\"Quote\"\\Slash");

		for (int i = 0; i < 1050; ++i)
		{
			LongTextSource += "t";
		}

		LongText = FText::FromString(LongTextSource);
	}

	UFUNCTION()
	bool Observe_LongTextSource_LengthBoundary()
	{
		return LongTextSource.Len() == 1050 && LongText.ToString().Len() == 1050;
	}

	UFUNCTION()
	bool Observe_EscapedText_Nominal()
	{
		return EscapedText.ToString() == "LineOne\nLineTwo\t\"Quote\"\\Slash";
	}
}
