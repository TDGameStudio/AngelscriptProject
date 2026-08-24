// Theme: Definitions.UFunction. WorldStory &out / const &in parameter matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::UParamDisplayNameAndRefMatrix block 1
// Oracle: ProcessWithOutParam(7,5) returns 37, Adjusted=35, LastResult=37; SplitWithRefs(41)->20,21;
// TransformString("Input") writes "Input:processed" to LastOutput.
// Extra: ProcessWithOutParam(0,0) empty; nullptr actor is the empty handle.
// FixtureIsolated. Keep LastResult / LastOutput names. Math::IntegerDivisionTrunc.

UCLASS()
class ACoverageUFunctionParamRefActor : AActor
{
	UPROPERTY()
	int LastResult = 0;

	UPROPERTY()
	FString LastOutput;

	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	int ProcessWithOutParam(int Input, int Scale, int&out Adjusted)
	{
		Adjusted = Input * Scale;
		LastResult = Adjusted + 2;
		return LastResult;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	void SplitWithRefs(int Source, int&out Left, int&out Right)
	{
		Left = Math::IntegerDivisionTrunc(Source, 2);
		Right = Source - Left;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	void TransformString(const FString&in Input, FString&out Output)
	{
		Output = Input + ":processed";
		LastOutput = Output;
	}
}

bool Observe_ParamRef_Nominal(ACoverageUFunctionParamRefActor Actor)
{
	int Adjusted = 0;
	int Returned = Actor.ProcessWithOutParam(7, 5, Adjusted);
	int Left = 0;
	int Right = 0;
	Actor.SplitWithRefs(41, Left, Right);
	FString Output = "";
	Actor.TransformString("Input", Output);
	return Returned == 37 && Adjusted == 35 && Actor.LastResult == 37
		&& Left == 20 && Right == 21
		&& Output == "Input:processed" && Actor.LastOutput == "Input:processed";
}

bool Observe_ParamRef_ZeroEmpty(ACoverageUFunctionParamRefActor Actor)
{
	int Adjusted = -1;
	int Returned = Actor.ProcessWithOutParam(0, 0, Adjusted);
	int Left = -1;
	int Right = -1;
	Actor.SplitWithRefs(0, Left, Right);
	FString Output = "stale";
	Actor.TransformString("", Output);
	return Returned == 2 && Adjusted == 0 && Actor.LastResult == 2
		&& Left == 0 && Right == 0
		&& Output == ":processed" && Actor.LastOutput == ":processed";
}

bool Observe_ParamRef_NullDefault()
{
	ACoverageUFunctionParamRefActor Actor = nullptr;
	return Actor == nullptr;
}
