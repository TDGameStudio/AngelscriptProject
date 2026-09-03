/**
 * A script actor seeds string-family members with special values: an empty
 * string, a 1024-character long string, escaped characters, unicode text, an
 * empty name, a dotted name, and unicode text. The observer confirms the
 * empty/long/name/text boundaries, while C++ verifies the escaped and unicode
 * values by path. The UPROPERTY names are read by path from C++ and must not
 * be renamed.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringSpecialValues
 * @Harness UClass
 * @Tag Language.Literals.StringSpecialValues
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::StringSpecialValues
 * @Provenance sha256=9c7d8b4ae64291a7717699cf0498dd4ae0adcca320799be1a6a05c9c2bf0e077; lines 838-885.
 * @Provenance Oracle: EmptyString ""; LongString 1024 x's; SpecialChars newline/tab/quote/backslash;
 * @Provenance UnicodeString "Hello 世界 🌍"; EmptyName NAME_None; SpecialName "Name.With.Dots-123";
 * @Provenance EmptyText empty; UnicodeText "Text 世界".
 * @Provenance Extra: defaults before BeginPlay are empty; LongString length is the 1024 boundary.
 * @Provenance FixtureIsolated. Keep UPROPERTY names used by VerifyByPath.
 */

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

	/**
	 * Seed the special string-family members during actor begin.
	 *
	 * @Covers Literals.FString
	 * @Inputs Empty, long, escaped, unicode, and name/text values
	 */
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

	/**
	 * Confirm the empty string, the 1024-character string, the empty name, and
	 * the empty text boundaries hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The members seeded by BeginPlay
	 * @Return true when the empty/long/name/text boundaries match
	 * @Boundary empty and 1024-length values
	 */
	UFUNCTION()
	bool VerifyEmptyAndLongBoundary()
	{
		if (EmptyString.Len() != 0)
		{
			return false;
		}
		if (LongString.Len() != 1024)
		{
			return false;
		}
		if (EmptyName != NAME_None)
		{
			return false;
		}
		return EmptyText.IsEmpty();
	}
}
