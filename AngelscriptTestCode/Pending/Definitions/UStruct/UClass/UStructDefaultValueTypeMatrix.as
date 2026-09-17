/**
 * @version v1
 * @summary CDO defaults plus an empty-container runtime mask. C++ reads Count, Weight, Label, Tag, State, and RuntimeEmptyContainerMask after BeginPlay.
 * @topic Definitions
 */
/**
 * @version root
 * @summary CDO defaults plus an empty-container runtime mask. C++ reads Count, Weight, Label, Tag, State, and RuntimeEmptyContainerMask after BeginPlay.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum EStructDefaultState
{
	None,
	Ready,
	Complete
}

USTRUCT(BlueprintType)
struct FStructDefaultValueMatrix
{
	UPROPERTY()
	bool bEnabled = true;

	UPROPERTY()
	int Count = 17;

	UPROPERTY()
	double Weight = 2.5;

	UPROPERTY()
	FString Label = "DefaultLabel";

	UPROPERTY()
	FName Tag = n"DefaultTag";

	UPROPERTY()
	EStructDefaultState State = EStructDefaultState::Ready;

	UPROPERTY()
	FVector Location = FVector(1, 2, 3);

	UPROPERTY()
	FRotator Rotation = FRotator(10, 20, 30);

	UPROPERTY()
	FVector2D Screen = FVector2D(4, 5);

	UPROPERTY()
	FColor Color = FColor(10, 20, 30, 40);

	UPROPERTY()
	FLinearColor LinearColor = FLinearColor(0.1, 0.2, 0.3, 0.4);

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	TArray<int> Numbers;

	UPROPERTY()
	TMap<FName, int> Scores;

	UPROPERTY()
	TSet<FName> Tags;
}

UCLASS()
class ACoverageStructDefaultValueActor : AActor
{
	UPROPERTY()
	FStructDefaultValueMatrix Data;

	UPROPERTY()
	int RuntimeEmptyContainerMask = 0;

	/**
	 * WorldStory: BeginPlay records which default containers and ActorRef are empty.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructDefaultValueTypeMatrix
	 * @Inputs none
	 * @Return RuntimeEmptyContainerMask 15 when all four empty bits are set
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Data.Numbers.Num() == 0)
		{
			RuntimeEmptyContainerMask |= 1;
		}

		if (Data.Scores.Num() == 0)
		{
			RuntimeEmptyContainerMask |= 2;
		}

		if (Data.Tags.Num() == 0)
		{
			RuntimeEmptyContainerMask |= 4;
		}

		if (Data.ActorRef == nullptr)
		{
			RuntimeEmptyContainerMask |= 8;
		}
	}

	/**
	 * Observe CDO defaults before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDefaultValueTypeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when Count/Weight/Label/Tag/State match and the mask is 0
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultValueMatrixCdoDefaults()
	{
		if (!Data.bEnabled)
		{
			return false;
		}
		if (Data.Count != 17)
		{
			return false;
		}
		if (Data.Weight != 2.5)
		{
			return false;
		}
		if (Data.Label != "DefaultLabel")
		{
			return false;
		}
		if (Data.Tag != n"DefaultTag")
		{
			return false;
		}
		if (Data.State != EStructDefaultState::Ready)
		{
			return false;
		}
		if (!Data.Location.Equals(FVector(1, 2, 3), 0.001))
		{
			return false;
		}
		if (Data.ActorRef != nullptr)
		{
			return false;
		}
		if (Data.Numbers.Num() != 0)
		{
			return false;
		}
		if (Data.Scores.Num() != 0)
		{
			return false;
		}
		if (Data.Tags.Num() != 0)
		{
			return false;
		}
		return RuntimeEmptyContainerMask == 0;
	}

	/**
	 * Observe the empty-container mask after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructDefaultValueTypeMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when RuntimeEmptyContainerMask is 15
	 */
	UFUNCTION()
	bool DefaultValueMatrixEmptyMaskAfterBeginPlay()
	{
		BeginPlay();
		return RuntimeEmptyContainerMask == 15;
	}

	/**
	 * Observe that filled containers leave only the null ActorRef bit.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDefaultValueTypeMatrix
	 * @Inputs Numbers/Scores/Tags filled then BeginPlay
	 * @Return true when RuntimeEmptyContainerMask is 8
	 * @Boundary filled containers
	 */
	UFUNCTION()
	bool DefaultValueMatrixFilledBoundary()
	{
		Data.Numbers.Add(1);
		Data.Scores.Add(n"Score", 2);
		Data.Tags.Add(n"Tag");
		BeginPlay();
		return RuntimeEmptyContainerMask == 8;
	}
}
/** @end */
