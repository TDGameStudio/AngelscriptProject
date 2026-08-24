// Theme: Definitions.UStruct. WorldStory: CDO defaults plus empty-container runtime mask.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDefaultValueTypeMatrix CDO + BeginPlay.
// Oracle: CDO Count 17 Weight 2.5 Label DefaultLabel Tag DefaultTag State Ready;
// RuntimeEmptyContainerMask 15 after BeginPlay. Extra: mask stays 0 without BeginPlay.
// FixtureIsolated.

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
}

bool Observe_DefaultValueMatrix_CdoDefaults(ACoverageStructDefaultValueActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDefaultValueTypeMatrix setup: required Actor is null");
	}
	return Actor.Data.bEnabled
		&& Actor.Data.Count == 17
		&& Actor.Data.Weight == 2.5
		&& Actor.Data.Label == "DefaultLabel"
		&& Actor.Data.Tag == n"DefaultTag"
		&& Actor.Data.State == EStructDefaultState::Ready
		&& Actor.Data.Location.Equals(FVector(1, 2, 3), 0.001)
		&& Actor.Data.ActorRef == nullptr
		&& Actor.Data.Numbers.Num() == 0
		&& Actor.Data.Scores.Num() == 0
		&& Actor.Data.Tags.Num() == 0
		&& Actor.RuntimeEmptyContainerMask == 0;
}

bool Observe_DefaultValueMatrix_EmptyMaskAfterBeginPlay(ACoverageStructDefaultValueActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDefaultValueTypeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.RuntimeEmptyContainerMask == 15;
}

bool Observe_DefaultValueMatrix_FilledBoundary(ACoverageStructDefaultValueActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDefaultValueTypeMatrix setup: required Actor is null");
	}
	Actor.Data.Numbers.Add(1);
	Actor.Data.Scores.Add(n"Score", 2);
	Actor.Data.Tags.Add(n"Tag");
	Actor.BeginPlay();
	return Actor.RuntimeEmptyContainerMask == 8;
}
