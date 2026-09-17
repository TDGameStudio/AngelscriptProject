/**
 * @version v1
 * @summary String-family members inside UE containers on an actor: TArray of FString, FName, and FText; TMap with string-family keys and values; and TSet of FString and FName. The observers confirm array order, empty text elements.
 * @topic Language
 */
/**
 * @version root
 * @summary String-family members inside UE containers on an actor: TArray of FString, FName, and FText; TMap with string-family keys and values; and TSet of FString and FName. The observers confirm array order, empty text elements.
 * @topic Baseline
 */
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

	/**
	 * Populate the string-family containers during actor begin.
	 *
	 * @Covers Literals.FString
	 * @Inputs Arrays, maps, and sets seeded with string-family values
	 */
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

	/**
	 * Confirm the populated containers read back their expected contents.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The containers built by BeginPlay
	 * @Return true when all array, map, and set expectations hold
	 */
	UFUNCTION()
	bool VerifyStringContainers()
	{
		if (StringArray.Num() != 3)
		{
			return false;
		}
		if (StringArray[0] != "First")
		{
			return false;
		}
		if (NameArray.Num() != 3)
		{
			return false;
		}
		if (NameArray[2] != NAME_None)
		{
			return false;
		}
		if (TextArray.Num() != 3)
		{
			return false;
		}
		if (!TextArray[2].IsEmpty())
		{
			return false;
		}
		if (StringToIntMap.Num() != 2)
		{
			return false;
		}
		if (IntToStringMap.Num() != 2)
		{
			return false;
		}
		if (NameToIntMap.Num() != 3)
		{
			return false;
		}
		if (StringSet.Num() != 2)
		{
			return false;
		}
		return NameSet.Num() == 2;
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

	/**
	 * Confirm the sibling actor's string-family containers default to empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The default array, set, and map
	 * @Return true when all three have zero elements
	 * @Boundary empty container defaults
	 */
	UFUNCTION()
	bool VerifyEmptyContainersDefault()
	{
		if (StringArray.Num() != 0)
		{
			return false;
		}
		if (StringSet.Num() != 0)
		{
			return false;
		}
		return StringToIntMap.Num() == 0;
	}
}
/** @end */
