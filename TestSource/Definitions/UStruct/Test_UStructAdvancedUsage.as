// Theme: Definitions.UStruct. WorldStory: constructors, opEquals, opCmp, opAdd, nested containers.
// C++: AngelscriptCoverageMacrosTests.cpp::UStructAdvancedUsage
// lines 1683-1810;
// sha256=f51c25ab1925422013e9cf3be0b93b825703bcf534ca2e4d0b67324f39058666.
// Oracle after BeginPlay: ComparisonResult=1, AdditionValue=300, ComplexData.Inner.Value=500.
// Extra: default FAdvancedStruct is empty; copy-independence after mutating the copy.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FAdvancedStruct
{
	UPROPERTY(BlueprintReadWrite, Category="Data")
	int Value = 0;

	UPROPERTY(BlueprintReadWrite, Category="Data")
	FString Name = "Default";

	UPROPERTY(BlueprintReadWrite, Category="Data")
	FVector Position;

	FAdvancedStruct()
	{
		Value = 0;
		Name = "Default";
		Position = FVector(0, 0, 0);
	}

	FAdvancedStruct(int InValue, FString InName)
	{
		Value = InValue;
		Name = InName;
		Position = FVector(0, 0, 0);
	}

	bool opEquals(const FAdvancedStruct&in Other) const
	{
		return Value == Other.Value && Name == Other.Name;
	}

	int opCmp(const FAdvancedStruct&in Other) const
	{
		if (Value < Other.Value)
		{
			return -1;
		}

		if (Value > Other.Value)
		{
			return 1;
		}

		return 0;
	}

	FAdvancedStruct opAdd(const FAdvancedStruct&in Other) const
	{
		FAdvancedStruct Result;
		Result.Value = Value + Other.Value;
		Result.Name = Name + Other.Name;
		Result.Position = Position + Other.Position;
		return Result;
	}
}

USTRUCT(BlueprintType)
struct FComplexStruct
{
	UPROPERTY(BlueprintReadWrite)
	FAdvancedStruct Inner;

	UPROPERTY(BlueprintReadWrite)
	TArray<FAdvancedStruct> StructArray;

	UPROPERTY(BlueprintReadWrite)
	TMap<int, FAdvancedStruct> StructMap;
}

UCLASS()
class ACoverageMacrosUStructActor : AActor
{
	UPROPERTY(BlueprintReadWrite)
	FAdvancedStruct Data1;

	UPROPERTY(BlueprintReadWrite)
	FAdvancedStruct Data2;

	UPROPERTY(BlueprintReadWrite)
	FComplexStruct ComplexData;

	UPROPERTY()
	int ComparisonResult = -1;

	UPROPERTY()
	int AdditionValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data1 = FAdvancedStruct(100, "First");
		Data2 = FAdvancedStruct(200, "Second");

		ComparisonResult = (Data1 == Data2) ? 0 : 1;
		check(ComparisonResult == 1);

		FAdvancedStruct Sum = Data1 + Data2;
		AdditionValue = Sum.Value;
		check(AdditionValue == 300);
		check(Sum.Name == "FirstSecond");

		ComplexData.Inner = FAdvancedStruct(500, "Inner");
		ComplexData.StructArray.Add(Data1);
		ComplexData.StructArray.Add(Data2);
		ComplexData.StructMap.Add(1, Data1);
		ComplexData.StructMap.Add(2, Data2);

		check(ComplexData.StructArray.Num() == 2);
		check(ComplexData.StructArray[0].Value == 100);
		check(ComplexData.StructArray[1].Value == 200);

		check(ComplexData.StructMap.Num() == 2);
		check(ComplexData.StructMap[1].Value == 100);
		check(ComplexData.StructMap[2].Value == 200);
	}
}

bool Observe_Advanced_DefaultEmpty()
{
	FAdvancedStruct Empty;
	return Empty.Value == 0 && Empty.Name == "Default" && Empty.Position.IsNearlyZero();
}

bool Observe_Advanced_EqualsFalse()
{
	FAdvancedStruct First(100, "First");
	FAdvancedStruct Second(200, "Second");
	return (First == Second) == false;
}

int Observe_Advanced_CmpLess()
{
	FAdvancedStruct First(100, "First");
	FAdvancedStruct Second(200, "Second");
	return First.opCmp(Second);
}

bool Observe_Advanced_AddNominal()
{
	FAdvancedStruct First(100, "First");
	FAdvancedStruct Second(200, "Second");
	FAdvancedStruct Sum = First + Second;
	return Sum.Value == 300 && Sum.Name == "FirstSecond";
}

bool Observe_Advanced_CopyIndependence()
{
	FAdvancedStruct Original(100, "First");
	FAdvancedStruct Copy = Original;
	Copy.Value = 0;
	Copy.Name = "";
	return Original.Value == 100 && Original.Name == "First" && Copy.Value == 0 && Copy.Name.IsEmpty();
}
