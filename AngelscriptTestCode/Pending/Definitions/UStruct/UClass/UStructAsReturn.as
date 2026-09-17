/**
 * @version v1
 * @summary Returning a USTRUCT from CreateStruct into Result. C++ reads Result after BeginPlay. Keep the UPROPERTY names ID, Description, Position, and Result.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Returning a USTRUCT from CreateStruct into Result. C++ reads Result after BeginPlay. Keep the UPROPERTY names ID, Description, Position, and Result.
 * @topic Baseline
 */
USTRUCT()
struct FReturnStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FString Description;

	UPROPERTY()
	FVector Position;
}

UCLASS()
class ACoverageStructReturnActor : AActor
{
	UPROPERTY()
	FReturnStruct Result;

	/**
	 * Build a return struct from an id and description.
	 *
	 * @Covers UStruct.UStructAsReturn
	 * @Inputs InID and InDesc
	 * @Return a struct whose Position is (InID*10, InID*20, InID*30)
	 * @Param InID the identifier
	 * @Param InDesc the description
	 */
	FReturnStruct CreateStruct(int InID, FString InDesc)
	{
		FReturnStruct New;
		New.ID = InID;
		New.Description = InDesc;
		New.Position = FVector(InID * 10.0f, InID * 20.0f, InID * 30.0f);
		return New;
	}

	/**
	 * WorldStory: BeginPlay stores CreateStruct(42, "Test Result") in Result.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructAsReturn
	 * @Inputs none
	 * @Return Result.ID 42, Description Test Result, Position (420,840,1260)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Result = CreateStruct(42, "Test Result");
	}

	/**
	 * Observe the empty Result before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAsReturn
	 * @Inputs an actor that has not begun play
	 * @Return true when ID is 0, Description is empty, and Position is nearly zero
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ReturnDefaultEmpty()
	{
		if (Result.ID != 0)
		{
			return false;
		}
		if (Result.Description.Len() != 0)
		{
			return false;
		}
		return Result.Position.IsNearlyZero();
	}

	/**
	 * Observe CreateStruct stored in Result after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructAsReturn
	 * @Inputs BeginPlay on this actor
	 * @Return true when Result matches the oracle
	 */
	UFUNCTION()
	bool ReturnNominalBeginPlay()
	{
		BeginPlay();
		if (Result.ID != 42)
		{
			return false;
		}
		if (Result.Description != "Test Result")
		{
			return false;
		}
		return Result.Position.Equals(FVector(420.0f, 840.0f, 1260.0f), 0.001);
	}

	/**
	 * Observe CreateStruct of zeros and an empty description.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAsReturn
	 * @Inputs CreateStruct(0, "")
	 * @Return true when ID is 0, Description is empty, and Position is the origin
	 * @Boundary zero id and empty description
	 */
	UFUNCTION()
	bool ReturnZeroBoundary()
	{
		FReturnStruct Empty = CreateStruct(0, "");
		if (Empty.ID != 0)
		{
			return false;
		}
		if (Empty.Description.Len() != 0)
		{
			return false;
		}
		return Empty.Position.Equals(FVector(0.0f, 0.0f, 0.0f), 0.001);
	}
}
/** @end */
