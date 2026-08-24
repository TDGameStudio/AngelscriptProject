// Theme: Language.Literals.FString. WorldStory actor string-family UPROPERTY defaults.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyDeclarationDefaults
// sha256=0d0ea2f9dcbc88c4a32203c2d733e462ae615818801915ab3b85ebdd56d3105c; lines 202-224.
// Oracle VerifyByPath: StringValue Hello; EmptyString ""; NoDefaultString ""; NameValue MyName;
// EmptyName NAME_None; TextValue empty.
// Extra: Observe helpers keep those UPROPERTY names; empty FText IsEmpty.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageFStringDefaultsActor : AActor
{
	UPROPERTY()
	FString StringValue = "Hello";

	UPROPERTY()
	FString EmptyString = "";

	UPROPERTY()
	FString NoDefaultString;

	UPROPERTY()
	FName NameValue = n"MyName";

	UPROPERTY()
	FName EmptyName = n"";

	UPROPERTY()
	FText TextValue;

	UFUNCTION()
	bool Observe_StringDefaults_Nominal()
	{
		return StringValue == "Hello"
			&& EmptyString == ""
			&& NoDefaultString == ""
			&& NameValue == n"MyName"
			&& EmptyName == n""
			&& TextValue.IsEmpty();
	}

	UFUNCTION()
	bool Observe_StringDefaults_EmptyFields()
	{
		return EmptyString.Len() == 0 && NoDefaultString == "" && EmptyName == n"";
	}

	UFUNCTION()
	bool Observe_StringValue_CopyIndependence()
	{
		FString Copy = StringValue;
		Copy = "Other";
		return StringValue == "Hello" && Copy == "Other";
	}
}
