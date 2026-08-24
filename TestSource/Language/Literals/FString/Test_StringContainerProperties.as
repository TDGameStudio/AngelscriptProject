// Theme: Language.Literals.FString. WorldStory: TArray/TMap/TSet of FString, FName, FText.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringContainerProperties
// sha256=43c37e0771069f0d60a9e8de66400732f7dd97965576d7f44624ff6d27fec21b; lines 1032-1105.
// Oracle: StringArray 3 (First/Second/Third); NameArray includes NAME_None;
// TextArray[2] empty; maps hold 2-3 entries; StringSet dedupes Apple to Num 2.
// Extra: sibling actor leaves containers empty (default Num 0).
// FixtureIsolated. Keep UPROPERTY names used by GetArrayNumByPath / VerifyByPath.

UCLASS()
class ACoverageFStringContainerActor : AActor
{
	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	TArray<FName> NameArray;

	UPROPERTY()
	TArray<FText> TextArray;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	UPROPERTY()
	TMap<int, FString> IntToStringMap;

	UPROPERTY()
	TMap<int, FName> IntToNameMap;

	UPROPERTY()
	TMap<int, FText> IntToTextMap;

	UPROPERTY()
	TMap<FName, int> NameToIntMap;

	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TSet<FName> NameSet;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringArray.Add("First");
		StringArray.Add("Second");
		StringArray.Add("Third");

		NameArray.Add(n"Alpha");
		NameArray.Add(n"Beta");
		NameArray.Add(NAME_None);

		TextArray.Add(FText::FromString("Text1"));
		TextArray.Add(FText::FromString("Text2"));
		TextArray.Add(FText::FromString(""));

		StringToIntMap.Add("One", 1);
		StringToIntMap.Add("Two", 2);

		IntToStringMap.Add(10, "Ten");
		IntToStringMap.Add(20, "Twenty");

		IntToNameMap.Add(10, n"TenName");
		IntToNameMap.Add(20, n"TwentyName");

		IntToTextMap.Add(10, FText::FromString("TenText"));
		IntToTextMap.Add(20, FText::FromString("TwentyText"));

		NameToIntMap.Add(n"First", 100);
		NameToIntMap.Add(n"Second", 200);
		NameToIntMap.Add(NAME_None, 300);

		StringSet.Add("Apple");
		StringSet.Add("Banana");
		StringSet.Add("Apple");  // Duplicate

		NameSet.Add(n"Tag1");
		NameSet.Add(n"Tag2");
	}

	UFUNCTION()
	bool Observe_StringContainers_Nominal()
	{
		return StringArray.Num() == 3
			&& StringArray[0] == "First"
			&& NameArray.Num() == 3
			&& NameArray[2] == NAME_None
			&& TextArray.Num() == 3
			&& TextArray[2].IsEmpty()
			&& StringToIntMap.Num() == 2
			&& IntToStringMap.Num() == 2
			&& NameToIntMap.Num() == 3
			&& StringSet.Num() == 2
			&& NameSet.Num() == 2;
	}
}

UCLASS()
class ACoverageFStringContainerActorEmpty : AActor
{
	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	UFUNCTION()
	bool Observe_EmptyContainers_Default()
	{
		return StringArray.Num() == 0 && StringSet.Num() == 0 && StringToIntMap.Num() == 0;
	}
}
