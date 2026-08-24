// Theme: Language.Literals.FString. WorldStory: reflected FString/FName/FText UPROPERTY write round-trip.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyWriteRoundTrip
// sha256=589a97b5e26091f999e279c59f462ddfaa81dbdba4103a66786b0ae3d94238d7; lines 281-294.
// Oracle: C++ SetByPath/VerifyByPath StringValue "Hello World" then empty;
// NameValue n"TestName"; TextValue written FText is readable.
// Extra: default empty FString/FName/FText; local rewrite is a value copy, not an alias.
// FixtureIsolated. Keep UPROPERTY names StringValue, NameValue, TextValue.

UCLASS()
class ACoverageFStringWriteActor : AActor
{
	UPROPERTY()
	FString StringValue;

	UPROPERTY()
	FName NameValue;

	UPROPERTY()
	FText TextValue;

	UFUNCTION()
	bool Observe_StringValue_ScriptRoundTrip()
	{
		StringValue = "Hello World";
		bool bHello = StringValue == "Hello World";
		StringValue = "";
		return bHello && StringValue.Len() == 0;
	}

	UFUNCTION()
	bool Observe_NameValue_EmptyDefaultAndBoundary()
	{
		bool bDefaultNone = NameValue == NAME_None;
		NameValue = n"TestName";
		FName Copy = NameValue;
		Copy = NAME_None;
		return bDefaultNone && NameValue == n"TestName" && Copy == NAME_None;
	}

	UFUNCTION()
	bool Observe_TextValue_EmptyDefault()
	{
		return TextValue.IsEmpty();
	}
}
