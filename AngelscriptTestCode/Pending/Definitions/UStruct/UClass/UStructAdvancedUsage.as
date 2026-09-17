/**
 * @version v1
 * @summary Constructors, opEquals, opCmp, opAdd, and nested containers on an advanced USTRUCT. C++ reads ComparisonResult, AdditionValue, and ComplexData.Inner after BeginPlay.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Constructors, opEquals, opCmp, opAdd, and nested containers on an advanced USTRUCT. C++ reads ComparisonResult, AdditionValue, and ComplexData.Inner after BeginPlay.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FAdvancedStruct
{
	UPROPERTY(BlueprintReadWrite, Category="Data")
	int Value = 0;

	UPROPERTY(BlueprintReadWrite, Category="Data")
	FString Name = "Default";

	UPROPERTY(BlueprintReadWrite, Category="Data")
	FVector Position;

	/**
	 * Default-construct Value 0, Name Default, and a zero Position.
	 *
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs none
	 * @Return a default FAdvancedStruct
	 */
	FAdvancedStruct()
	{
		Value = 0;
		Name = "Default";
		Position = FVector(0, 0, 0);
	}

	/**
	 * Construct from a value and name with a zero Position.
	 *
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs InValue and InName
	 * @Return an FAdvancedStruct holding those fields
	 * @Param InValue the value
	 * @Param InName the name
	 */
	FAdvancedStruct(int InValue, FString InName)
	{
		Value = InValue;
		Name = InName;
		Position = FVector(0, 0, 0);
	}

	/**
	 * Compare two instances by Value and Name.
	 *
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs another FAdvancedStruct
	 * @Return true when Value and Name match
	 * @Param Other the other instance
	 */
	bool opEquals(const FAdvancedStruct&in Other) const
	{
		if (Value != Other.Value)
		{
			return false;
		}
		return Name == Other.Name;
	}

	/**
	 * Compare two instances by Value.
	 *
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs another FAdvancedStruct
	 * @Return -1, 0, or 1
	 * @Param Other the other instance
	 */
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

	/**
	 * Add two instances component-wise, concatenating Name.
	 *
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs another FAdvancedStruct
	 * @Return the sum
	 * @Param Other the other instance
	 */
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

	/**
	 * WorldStory: BeginPlay constructs, compares, adds, and nests advanced structs.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs none
	 * @Return ComparisonResult 1, AdditionValue 300, ComplexData.Inner.Value 500
	 */
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

	/**
	 * Observe the default constructor result.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs a default-constructed FAdvancedStruct
	 * @Return true when Value is 0, Name is Default, and Position is nearly zero
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool AdvancedDefaultEmpty()
	{
		FAdvancedStruct Empty;
		if (Empty.Value != 0)
		{
			return false;
		}
		if (Empty.Name != "Default")
		{
			return false;
		}
		return Empty.Position.IsNearlyZero();
	}

	/**
	 * Observe that unequal constructed instances compare false.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs First(100, First) and Second(200, Second)
	 * @Return true when they compare unequal
	 */
	UFUNCTION()
	bool AdvancedEqualsFalse()
	{
		FAdvancedStruct First(100, "First");
		FAdvancedStruct Second(200, "Second");
		bool AreEqual = (First == Second);
		return AreEqual == false;
	}

	/**
	 * Observe opCmp when the left Value is smaller.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs First(100, First) and Second(200, Second)
	 * @Return -1
	 */
	UFUNCTION()
	int AdvancedCmpLess()
	{
		FAdvancedStruct First(100, "First");
		FAdvancedStruct Second(200, "Second");
		return First.opCmp(Second);
	}

	/**
	 * Observe opAdd concatenating Value and Name.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs First(100, First) + Second(200, Second)
	 * @Return true when the sum is 300/FirstSecond
	 */
	UFUNCTION()
	bool AdvancedAddNominal()
	{
		FAdvancedStruct First(100, "First");
		FAdvancedStruct Second(200, "Second");
		FAdvancedStruct Sum = First + Second;
		if (Sum.Value != 300)
		{
			return false;
		}
		return Sum.Name == "FirstSecond";
	}

	/**
	 * Observe that copying an advanced struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedUsage
	 * @Inputs a copy whose Value and Name were cleared
	 * @Return true when the original keeps 100/First and the copy is empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AdvancedCopyIndependence()
	{
		FAdvancedStruct Original(100, "First");
		FAdvancedStruct Copy = Original;
		Copy.Value = 0;
		Copy.Name = "";
		if (Original.Value != 100)
		{
			return false;
		}
		if (Original.Name != "First")
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.Name.IsEmpty();
	}
}
/** @end */
