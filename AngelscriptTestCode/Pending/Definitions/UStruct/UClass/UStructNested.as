/**
 * @version v1
 * @summary Nested FInner/FMiddle/FOuter structs and arrays on an actor. C++ reads the nested paths after BeginPlay. Keep the UPROPERTY names on each layer.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Nested FInner/FMiddle/FOuter structs and arrays on an actor. C++ reads the nested paths after BeginPlay. Keep the UPROPERTY names on each layer.
 * @topic Baseline
 */
USTRUCT()
struct FInnerStruct
{
	UPROPERTY()
	int InnerValue = 0;

	UPROPERTY()
	FString InnerName;
}

USTRUCT()
struct FMiddleStruct
{
	UPROPERTY()
	int MiddleValue = 0;

	UPROPERTY()
	FInnerStruct InnerData;

	UPROPERTY()
	TArray<FInnerStruct> InnerArray;
}

USTRUCT()
struct FOuterStruct
{
	UPROPERTY()
	int OuterValue = 0;

	UPROPERTY()
	FMiddleStruct MiddleData;

	UPROPERTY()
	FInnerStruct DirectInner;

	UPROPERTY()
	TArray<FMiddleStruct> MiddleArray;
}

UCLASS()
class ACoverageStructNestedActor : AActor
{
	UPROPERTY()
	FOuterStruct NestedData;

	/**
	 * WorldStory: BeginPlay fills every nested path C++ reads by path.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructNested
	 * @Inputs none
	 * @Return NestedData holds the oracle nested values after BeginPlay
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NestedData.OuterValue = 100;

		NestedData.MiddleData.MiddleValue = 200;

		NestedData.MiddleData.InnerData.InnerValue = 300;
		NestedData.MiddleData.InnerData.InnerName = "DeepInner";

		NestedData.DirectInner.InnerValue = 400;
		NestedData.DirectInner.InnerName = "DirectInner";

		FInnerStruct Inner1;
		Inner1.InnerValue = 301;
		Inner1.InnerName = "Inner1";
		NestedData.MiddleData.InnerArray.Add(Inner1);

		FInnerStruct Inner2;
		Inner2.InnerValue = 302;
		Inner2.InnerName = "Inner2";
		NestedData.MiddleData.InnerArray.Add(Inner2);

		FMiddleStruct Middle1;
		Middle1.MiddleValue = 201;
		Middle1.InnerData.InnerValue = 311;
		Middle1.InnerData.InnerName = "MiddleArray1Inner";
		NestedData.MiddleArray.Add(Middle1);

		FMiddleStruct Middle2;
		Middle2.MiddleValue = 202;
		Middle2.InnerData.InnerValue = 312;
		Middle2.InnerData.InnerName = "MiddleArray2Inner";
		NestedData.MiddleArray.Add(Middle2);
	}

	/**
	 * Observe nested defaults before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNested
	 * @Inputs an actor that has not begun play
	 * @Return true when nested values are zero and arrays are empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool NestedDefaultEmpty()
	{
		if (NestedData.OuterValue != 0)
		{
			return false;
		}
		if (NestedData.MiddleData.MiddleValue != 0)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerData.InnerValue != 0)
		{
			return false;
		}
		if (NestedData.DirectInner.InnerName.Len() != 0)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerArray.Num() != 0)
		{
			return false;
		}
		return NestedData.MiddleArray.Num() == 0;
	}

	/**
	 * Observe nested values after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructNested
	 * @Inputs BeginPlay on this actor
	 * @Return true when every nested oracle value matches
	 */
	UFUNCTION()
	bool NestedNominalBeginPlay()
	{
		BeginPlay();
		if (NestedData.OuterValue != 100)
		{
			return false;
		}
		if (NestedData.MiddleData.MiddleValue != 200)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerData.InnerValue != 300)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerData.InnerName != "DeepInner")
		{
			return false;
		}
		if (NestedData.DirectInner.InnerValue != 400)
		{
			return false;
		}
		if (NestedData.DirectInner.InnerName != "DirectInner")
		{
			return false;
		}
		if (NestedData.MiddleData.InnerArray.Num() != 2)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerArray[0].InnerValue != 301)
		{
			return false;
		}
		if (NestedData.MiddleData.InnerArray[1].InnerName != "Inner2")
		{
			return false;
		}
		if (NestedData.MiddleArray.Num() != 2)
		{
			return false;
		}
		if (NestedData.MiddleArray[0].MiddleValue != 201)
		{
			return false;
		}
		return NestedData.MiddleArray[1].InnerData.InnerValue == 312;
	}

	/**
	 * Observe that a second actor is independent of this actor's BeginPlay fill.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNested
	 * @Inputs this actor after BeginPlay and a second unfilled actor
	 * @Return true when this actor holds 100 and the second stays empty
	 * @Param Second the other actor supplied by the runner
	 * @Boundary two-instance independence
	 */
	UFUNCTION()
	bool NestedCopyIndependence(ACoverageStructNestedActor Second)
	{
		if (Second == nullptr)
		{
			throw("UStructNested setup: required Second is null");
		}
		BeginPlay();
		if (NestedData.OuterValue != 100)
		{
			return false;
		}
		if (Second.NestedData.OuterValue != 0)
		{
			return false;
		}
		return Second.NestedData.MiddleArray.Num() == 0;
	}
}
/** @end */
