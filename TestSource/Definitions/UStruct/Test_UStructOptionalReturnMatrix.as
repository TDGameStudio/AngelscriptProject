// Theme: Definitions.UStruct. WorldStory: TOptional<FStruct> return set vs empty.
// C++: AngelscriptCoverageUStructTests.cpp::UStructOptionalReturnMatrix.
// Oracle: ReturnSetPayload IsSet Count 64 Label OptionalReturn; ReturnEmptyPayload !IsSet.
// Extra: default flags false / Count 0. FixtureIsolated.

USTRUCT(BlueprintType)
struct FOptionalReturnPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructOptionalReturnActor : AActor
{
	UPROPERTY()
	bool bSetReturnObserved = false;

	UPROPERTY()
	bool bEmptyReturnObserved = false;

	UPROPERTY()
	int LastSetCount = 0;

	UPROPERTY()
	FString LastSetLabel;

	UFUNCTION(BlueprintCallable)
	TOptional<FOptionalReturnPayload> ReturnSetPayload()
	{
		FOptionalReturnPayload Payload;
		Payload.Count = 64;
		Payload.Label = "OptionalReturn";

		TOptional<FOptionalReturnPayload> Result;
		Result.Set(Payload);

		TOptional<FOptionalReturnPayload> Observed = Result;
		bSetReturnObserved = Observed.IsSet();
		LastSetCount = Observed.GetValue().Count;
		LastSetLabel = Observed.GetValue().Label;
		return Result;
	}

	UFUNCTION(BlueprintCallable)
	TOptional<FOptionalReturnPayload> ReturnEmptyPayload()
	{
		TOptional<FOptionalReturnPayload> Result;
		bEmptyReturnObserved = !Result.IsSet();
		return Result;
	}
}

bool Observe_OptionalReturn_DefaultEmpty(ACoverageStructOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOptionalReturnMatrix setup: required Actor is null");
	}
	return !Actor.bSetReturnObserved && !Actor.bEmptyReturnObserved && Actor.LastSetCount == 0 && Actor.LastSetLabel.Len() == 0;
}

bool Observe_OptionalReturn_SetPayload(ACoverageStructOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOptionalReturnMatrix setup: required Actor is null");
	}
	TOptional<FOptionalReturnPayload> Result = Actor.ReturnSetPayload();
	return Result.IsSet()
		&& Actor.bSetReturnObserved
		&& Actor.LastSetCount == 64
		&& Actor.LastSetLabel == "OptionalReturn"
		&& Result.GetValue().Count == 64;
}

bool Observe_OptionalReturn_EmptyBoundary(ACoverageStructOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOptionalReturnMatrix setup: required Actor is null");
	}
	TOptional<FOptionalReturnPayload> Result = Actor.ReturnEmptyPayload();
	return !Result.IsSet() && Actor.bEmptyReturnObserved;
}
