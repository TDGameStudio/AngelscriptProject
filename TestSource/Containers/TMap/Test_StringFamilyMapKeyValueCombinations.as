// Theme: Containers.TMap. WorldStory: FString/FName/FText map key-value combinations.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyMapKeyValueCombinations
// reflects FMapProperty key/value types and BeginPlay inserts one pair per map.
// Extra: maps default empty until BeginPlay; n"" FName keys stay copy-independent of FString keys.
// FixtureIsolated.

UCLASS()
class ACoverageFStringMapCombinationsActor : AActor
{
	UPROPERTY()
	TMap<FString, FName> StringToNameMap;

	UPROPERTY()
	TMap<FString, FText> StringToTextMap;

	UPROPERTY()
	TMap<FName, FString> NameToStringMap;

	UPROPERTY()
	TMap<FName, FText> NameToTextMap;

	UPROPERTY()
	TMap<FName, FName> NameToNameMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringToNameMap.Add("StringKey", n"StringName");
		StringToTextMap.Add("TextKey", FText::FromString("String Text Value"));

		NameToStringMap.Add(n"NameKey", "Name String Value");
		NameToTextMap.Add(n"NameTextKey", FText::FromString("Name Text Value"));
		NameToNameMap.Add(n"OuterName", n"InnerName");
	}
}
