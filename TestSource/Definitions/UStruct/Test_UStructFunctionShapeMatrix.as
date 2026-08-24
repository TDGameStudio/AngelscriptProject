// Theme: Definitions.UStruct. WorldStory: function-shape matrix for local/value/in/out/inout/return/array/map.
// C++: AngelscriptCoverageUStructTests.cpp::UStructFunctionShapeMatrix spawn + BeginPlay.
// Oracle: Local 1/Local, Value 11/Local_Value, In 21/Local_In, Out 30/Out, Inout 41/Local_Inout,
// Return 50/Return. Extra: empty ArrayResult/MapResult before BeginPlay. FixtureIsolated.

USTRUCT(BlueprintType)
struct FShapeStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructFunctionShapeActor : AActor
{
	UPROPERTY()
	FShapeStruct LocalResult;

	UPROPERTY()
	FShapeStruct ValueResult;

	UPROPERTY()
	FShapeStruct InResult;

	UPROPERTY()
	FShapeStruct OutResult;

	UPROPERTY()
	FShapeStruct InoutResult;

	UPROPERTY()
	FShapeStruct ReturnResult;

	UPROPERTY()
	TArray<FShapeStruct> ArrayResult;

	UPROPERTY()
	TMap<int, FShapeStruct> MapResult;

	FShapeStruct MakeStruct(int Value, FString Label)
	{
		FShapeStruct Result;
		Result.Value = Value;
		Result.Label = Label;
		return Result;
	}

	FShapeStruct AcceptValue(FShapeStruct Param)
	{
		// By-value UStruct params are immutable in this fork; mutate a local copy.
		FShapeStruct Result = Param;
		Result.Value += 10;
		Result.Label += "_Value";
		return Result;
	}

	FShapeStruct AcceptConstRef(const FShapeStruct&in Param)
	{
		FShapeStruct Result;
		Result.Value = Param.Value + 20;
		Result.Label = Param.Label + "_In";
		return Result;
	}

	void FillOut(FShapeStruct&out Param)
	{
		Param.Value = 30;
		Param.Label = "Out";
	}

	int MutateInout(FShapeStruct&inout Param)
	{
		Param.Value += 40;
		Param.Label += "_Inout";
		return Param.Value;
	}

	TArray<FShapeStruct> MakeArray(FShapeStruct First, const FShapeStruct&in Second)
	{
		TArray<FShapeStruct> Result;
		Result.Add(First);
		Result.Add(Second);
		return Result;
	}

	TMap<int, FShapeStruct> MakeMap(const FShapeStruct&in First, const FShapeStruct&in Second)
	{
		TMap<int, FShapeStruct> Result;
		Result.Add(1, First);
		Result.Add(2, Second);
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FShapeStruct Local;
		Local.Value = 1;
		Local.Label = "Local";
		LocalResult = Local;

		ValueResult = AcceptValue(Local);
		InResult = AcceptConstRef(Local);
		FillOut(OutResult);

		InoutResult = Local;
		MutateInout(InoutResult);

		ReturnResult = MakeStruct(50, "Return");
		ArrayResult = MakeArray(ValueResult, InResult);
		MapResult = MakeMap(OutResult, InoutResult);
	}
}

bool Observe_FunctionShape_DefaultEmpty(ACoverageStructFunctionShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructFunctionShapeMatrix setup: required Actor is null");
	}
	return Actor.LocalResult.Value == 0
		&& Actor.ArrayResult.Num() == 0
		&& Actor.MapResult.Num() == 0;
}

bool Observe_FunctionShape_NominalBeginPlay(ACoverageStructFunctionShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructFunctionShapeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	FShapeStruct MapOut;
	FShapeStruct MapInout;
	return Actor.LocalResult.Value == 1
		&& Actor.LocalResult.Label == "Local"
		&& Actor.ValueResult.Value == 11
		&& Actor.ValueResult.Label == "Local_Value"
		&& Actor.InResult.Value == 21
		&& Actor.InResult.Label == "Local_In"
		&& Actor.OutResult.Value == 30
		&& Actor.OutResult.Label == "Out"
		&& Actor.InoutResult.Value == 41
		&& Actor.InoutResult.Label == "Local_Inout"
		&& Actor.ReturnResult.Value == 50
		&& Actor.ReturnResult.Label == "Return"
		&& Actor.ArrayResult.Num() == 2
		&& Actor.ArrayResult[0].Value == 11
		&& Actor.ArrayResult[1].Value == 21
		&& Actor.MapResult.Num() == 2
		&& Actor.MapResult.Find(1, MapOut) && MapOut.Value == 30
		&& Actor.MapResult.Find(2, MapInout) && MapInout.Value == 41;
}

int Observe_FunctionShape_EmptyMakeArray(ACoverageStructFunctionShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructFunctionShapeMatrix setup: required Actor is null");
	}
	FShapeStruct First;
	FShapeStruct Second;
	TArray<FShapeStruct> Items = Actor.MakeArray(First, Second);
	return Items.Num();
}
