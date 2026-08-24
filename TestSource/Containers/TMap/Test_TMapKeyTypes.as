// Theme: Containers.TMap. WorldStory: FString / FName / enum class keys.
// C++ GetMapNum 3 per map; StringKeyMap["Beta"]=200; NameKeyMap n"Green"=2;
// EnumKeyMap has First/Second/Third. Extra: maps default empty until BeginPlay.
// FixtureIsolated.

enum class ETestEnum
{
	First,
	Second,
	Third
}

UCLASS()
class ACoverageTMapKeyTypesActor : AActor
{
	UPROPERTY()
	TMap<FString, int> StringKeyMap;

	UPROPERTY()
	TMap<FName, int> NameKeyMap;

	UPROPERTY()
	TMap<ETestEnum, FString> EnumKeyMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// FString keys
		StringKeyMap.Add("Alpha", 100);
		StringKeyMap.Add("Beta", 200);
		StringKeyMap.Add("Gamma", 300);

		// FName keys
		NameKeyMap.Add(n"Red", 1);
		NameKeyMap.Add(n"Green", 2);
		NameKeyMap.Add(n"Blue", 3);

		// Enum keys
		EnumKeyMap.Add(ETestEnum::First, "FirstValue");
		EnumKeyMap.Add(ETestEnum::Second, "SecondValue");
		EnumKeyMap.Add(ETestEnum::Third, "ThirdValue");
	}
}
