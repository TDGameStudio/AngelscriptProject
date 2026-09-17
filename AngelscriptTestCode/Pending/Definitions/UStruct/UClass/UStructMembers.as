/**
 * @version v1
 * @summary Mixed USTRUCT member types filled in BeginPlay. C++ reads each field by path after the actor has begun play. Keep the UPROPERTY names on FComplexStruct.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Mixed USTRUCT member types filled in BeginPlay. C++ reads each field by path after the actor has begun play. Keep the UPROPERTY names on FComplexStruct.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FComplexStruct
{
	UPROPERTY(EditAnywhere)
	int IntValue = 0;

	UPROPERTY(EditAnywhere)
	float FloatValue = 0.0f;

	UPROPERTY(EditAnywhere)
	bool BoolValue = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString StringValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FName NameValue;

	UPROPERTY(EditAnywhere)
	FVector VectorValue;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	TArray<FString> StringArray;
}

UCLASS()
class ACoverageStructMemberActor : AActor
{
	UPROPERTY()
	FComplexStruct Data;

	/**
	 * WorldStory: BeginPlay fills every mixed member C++ reads by path.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructMembers
	 * @Inputs none
	 * @Return Data holds the oracle values after BeginPlay
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.IntValue = 42;
		Data.FloatValue = 3.14f;
		Data.BoolValue = true;
		Data.StringValue = "Hello";
		Data.NameValue = n"TestName";
		Data.VectorValue = FVector(1.0f, 2.0f, 3.0f);
		Data.ActorRef = this;
		Data.IntArray.Add(10);
		Data.IntArray.Add(20);
		Data.StringArray.Add("First");
		Data.StringArray.Add("Second");
	}

	/**
	 * Observe the mixed-member defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMembers
	 * @Inputs a default-constructed FComplexStruct
	 * @Return true when every member is zero, empty, false, or null
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool ComplexDefaultEmpty()
	{
		FComplexStruct LocalData;
		if (LocalData.IntValue != 0)
		{
			return false;
		}
		if (LocalData.FloatValue != 0.0f)
		{
			return false;
		}
		if (LocalData.BoolValue != false)
		{
			return false;
		}
		if (!LocalData.StringValue.IsEmpty())
		{
			return false;
		}
		if (LocalData.NameValue != NAME_None)
		{
			return false;
		}
		if (!LocalData.VectorValue.IsNearlyZero())
		{
			return false;
		}
		if (LocalData.ActorRef != nullptr)
		{
			return false;
		}
		if (LocalData.IntArray.Num() != 0)
		{
			return false;
		}
		return LocalData.StringArray.Num() == 0;
	}

	/**
	 * Observe a local fill matching the BeginPlay oracle.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMembers
	 * @Inputs a struct filled with the oracle values
	 * @Return true when every filled member matches
	 */
	UFUNCTION()
	bool ComplexNominalFill()
	{
		FComplexStruct LocalData;
		LocalData.IntValue = 42;
		LocalData.FloatValue = 3.14f;
		LocalData.BoolValue = true;
		LocalData.StringValue = "Hello";
		LocalData.NameValue = n"TestName";
		LocalData.VectorValue = FVector(1.0f, 2.0f, 3.0f);
		LocalData.IntArray.Add(10);
		LocalData.IntArray.Add(20);
		LocalData.StringArray.Add("First");
		LocalData.StringArray.Add("Second");
		if (LocalData.IntValue != 42)
		{
			return false;
		}
		if (LocalData.FloatValue != 3.14f)
		{
			return false;
		}
		if (LocalData.BoolValue != true)
		{
			return false;
		}
		if (LocalData.StringValue != "Hello")
		{
			return false;
		}
		if (LocalData.NameValue != n"TestName")
		{
			return false;
		}
		if (!LocalData.VectorValue.Equals(FVector(1.0f, 2.0f, 3.0f)))
		{
			return false;
		}
		if (LocalData.IntArray[0] != 10)
		{
			return false;
		}
		if (LocalData.IntArray[1] != 20)
		{
			return false;
		}
		if (LocalData.StringArray[0] != "First")
		{
			return false;
		}
		return LocalData.StringArray[1] == "Second";
	}

	/**
	 * Observe that copying the mixed struct does not alias scalar or array members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMembers
	 * @Inputs a copy whose IntValue and IntArray[0] were mutated
	 * @Return true when the original keeps 42/10 and the copy holds 0/99
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ComplexCopyIndependence()
	{
		FComplexStruct Original;
		Original.IntValue = 42;
		Original.IntArray.Add(10);
		FComplexStruct Copy = Original;
		Copy.IntValue = 0;
		Copy.IntArray[0] = 99;
		if (Original.IntValue != 42)
		{
			return false;
		}
		if (Original.IntArray[0] != 10)
		{
			return false;
		}
		if (Copy.IntValue != 0)
		{
			return false;
		}
		return Copy.IntArray[0] == 99;
	}
}
/** @end */
