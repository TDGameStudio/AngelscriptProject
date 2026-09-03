/**
 * TArray/TSet/TMap of scalars, names, text, vectors, and actors. C++ verifies
 * named members by path, so those UPROPERTY names are kept. The observers cover
 * empty IntArray Num 0 and a missing map key.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassContainerMemberMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassContainerMemberMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: TArray/TSet/TMap of scalars, names, text, vectors, and actors.
 * @Provenance C++: container members reflect; VectorMapFirstX/SecondY/SecondZ from IntToVectorMap; StringSet dedupes SetAlpha.
 * @Provenance Extra: empty IntArray Num 0; missing map key is independent of filled entries. FixtureIsolated.
 */

UCLASS()
class ACoverageUClassContainerTargetActor : AActor
{
}

UCLASS()
class ACoverageUClassContainerMemberActor : AActor
{
	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	TArray<bool> BoolArray;

	UPROPERTY()
	TArray<double> DoubleArray;

	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	TArray<FName> NameArray;

	UPROPERTY()
	TArray<FText> TextArray;

	UPROPERTY()
	TArray<FVector> VectorArray;

	UPROPERTY()
	TArray<AActor> ActorArray;

	UPROPERTY()
	TSet<int> IntSet;

	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TSet<FName> NameSet;

	UPROPERTY()
	TSet<FVector> VectorSet;

	UPROPERTY()
	TMap<int, FString> IntToStringMap;

	UPROPERTY()
	TMap<int, FName> IntToNameMap;

	UPROPERTY()
	TMap<int, FText> IntToTextMap;

	UPROPERTY()
	TMap<FName, int> NameToIntMap;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

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

	UPROPERTY()
	TMap<int, FVector> IntToVectorMap;

	UPROPERTY()
	double VectorMapSecondZ = 0.0;

	UPROPERTY()
	double VectorMapFirstX = 0.0;

	UPROPERTY()
	double VectorMapSecondY = 0.0;

	/**
	 * WorldStory: fill every container member after play begins.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassContainerMemberMatrix
	 * @Inputs none
	 * @Return VectorMapFirstX/SecondY/SecondZ filled; StringSet dedupes SetAlpha
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		IntArray.Add(7);
		IntArray.Add(11);
		BoolArray.Add(true);
		BoolArray.Add(false);
		DoubleArray.Add(2.25);
		DoubleArray.Add(4.5);
		StringArray.Add("First");
		StringArray.Add("Second");
		NameArray.Add(n"NameArrayFirst");
		NameArray.Add(n"NameArraySecond");
		TextArray.Add(FText::FromString("TextFirst"));
		TextArray.Add(FText::FromString("TextSecond"));
		VectorArray.Add(FVector(1, 2, 3));
		VectorArray.Add(FVector(4, 5, 6));
		ActorArray.Add(this);
		ActorArray.Add(SpawnActor(ACoverageUClassContainerTargetActor::StaticClass()));
		IntSet.Add(13);
		IntSet.Add(17);
		StringSet.Add("SetAlpha");
		StringSet.Add("SetAlpha");
		StringSet.Add("SetBeta");
		NameSet.Add(n"FirstName");
		NameSet.Add(n"SecondName");
		VectorSet.Add(FVector::ForwardVector);
		VectorSet.Add(FVector::RightVector);
		IntToStringMap.Add(19, "Nineteen");
		IntToStringMap.Add(23, "TwentyThree");
		IntToNameMap.Add(53, n"FiftyThreeName");
		IntToNameMap.Add(59, n"FiftyNineName");
		IntToTextMap.Add(37, FText::FromString("ThirtySevenText"));
		IntToTextMap.Add(41, FText::FromString("FortyOneText"));
		NameToIntMap.Add(n"Alpha", 29);
		NameToIntMap.Add(n"Beta", 31);
		StringToIntMap.Add("ScoreA", 43);
		StringToIntMap.Add("ScoreB", 47);
		StringToNameMap.Add("StringNameKey", n"StringNameValue");
		StringToTextMap.Add("StringTextKey", FText::FromString("String Text Value"));
		NameToStringMap.Add(n"NameStringKey", "Name String Value");
		NameToTextMap.Add(n"NameTextKey", FText::FromString("Name Text Value"));
		NameToNameMap.Add(n"OuterName", n"InnerName");
		IntToVectorMap.Add(1, FVector::ForwardVector);
		IntToVectorMap.Add(2, FVector(6, 7, 8));
		VectorMapFirstX = IntToVectorMap[1].X;
		VectorMapSecondY = IntToVectorMap[2].Y;
		VectorMapSecondZ = IntToVectorMap[2].Z;
	}

	/**
	 * Observe that an empty IntArray has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassContainerMemberMatrix
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int ContainerMemberEmptyIntArrayNum()
	{
		TArray<int> IntArray;
		return IntArray.Num();
	}

	/**
	 * Observe that a missing map key does not find an entry.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassContainerMemberMatrix
	 * @Inputs an empty IntToStringMap
	 * @Return true when Find(19) fails
	 * @Boundary missing key
	 */
	UFUNCTION()
	bool ContainerMemberMissingMapKey()
	{
		TMap<int, FString> IntToStringMap;
		FString Found;
		return !IntToStringMap.Find(19, Found);
	}
}
