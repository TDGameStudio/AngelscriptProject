// Theme: Definitions.UStruct. WorldStory: returning a USTRUCT from CreateStruct.
// C++: AngelscriptCoverageUStructTests.cpp::UStructAsReturn spawn + BeginPlay.
// Oracle: Result.ID 42, Description "Test Result", Position (420,840,1260).
// Extra: CreateStruct(0,"") yields zeros and empty description. FixtureIsolated.

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

	FReturnStruct CreateStruct(int InID, FString InDesc)
	{
		FReturnStruct New;
		New.ID = InID;
		New.Description = InDesc;
		New.Position = FVector(InID * 10.0f, InID * 20.0f, InID * 30.0f);
		return New;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Result = CreateStruct(42, "Test Result");
	}
}

bool Observe_Return_DefaultEmpty(ACoverageStructReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsReturn setup: required Actor is null");
	}
	return Actor.Result.ID == 0 && Actor.Result.Description.Len() == 0 && Actor.Result.Position.IsNearlyZero();
}

bool Observe_Return_NominalBeginPlay(ACoverageStructReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsReturn setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Result.ID == 42
		&& Actor.Result.Description == "Test Result"
		&& Actor.Result.Position.Equals(FVector(420.0f, 840.0f, 1260.0f), 0.001);
}

bool Observe_Return_ZeroBoundary(ACoverageStructReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsReturn setup: required Actor is null");
	}
	FReturnStruct Empty = Actor.CreateStruct(0, "");
	return Empty.ID == 0 && Empty.Description.Len() == 0 && Empty.Position.Equals(FVector(0.0f, 0.0f, 0.0f), 0.001);
}
