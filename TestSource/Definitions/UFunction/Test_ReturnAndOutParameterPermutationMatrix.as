// Theme: Definitions.UFunction. WorldStory: return plus primitive/struct out/inout permutation.
// C++: AngelscriptCoverageUFunctionTests.cpp::ReturnAndOutParameterPermutationMatrix
// Oracle: ReturnAndWritePrimitiveOuts(21) == 65 OutInt 31 bOutBool true OutLabel PrimitiveOut;
// ReturnStructAndWriteMixedOuts(11, InOutScore 0) LastScore 42 LastLabel ReturnPayload.
// Extra: BaseValue 0 writes OutInt 10 bOutBool false; default LastScore 0 LastLabel empty.
// FixtureIsolated. Runner owns World teardown.

USTRUCT(BlueprintType)
struct FUFunctionReturnOutPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUFunctionReturnOutActor : AActor
{
	UPROPERTY()
	int LastScore = 0;

	UPROPERTY()
	FString LastLabel;

	UFUNCTION(BlueprintCallable, Category="Coverage|ReturnOut")
	int ReturnAndWritePrimitiveOuts(int BaseValue, int&out OutInt, bool&out bOutBool, FString&out OutLabel)
	{
		OutInt = BaseValue + 10;
		bOutBool = BaseValue > 0;
		OutLabel = "PrimitiveOut";
		LastScore = BaseValue + OutInt + (bOutBool ? 1 : 0) + OutLabel.Len();
		LastLabel = OutLabel;
		return LastScore;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|ReturnOut")
	FUFunctionReturnOutPayload ReturnStructAndWriteMixedOuts(int BaseValue, FUFunctionReturnOutPayload&out OutPayload, FVector&out OutLocation, int&inout InOutScore)
	{
		OutPayload.Count = BaseValue + 20;
		OutPayload.Label = "OutPayload";
		OutLocation = FVector(BaseValue, BaseValue + 1, BaseValue + 2);
		InOutScore += OutPayload.Count + int(OutLocation.X);

		FUFunctionReturnOutPayload ReturnPayload;
		ReturnPayload.Count = InOutScore;
		ReturnPayload.Label = "ReturnPayload";
		LastScore = InOutScore;
		LastLabel = ReturnPayload.Label;
		return ReturnPayload;
	}
}

int Observe_ReturnOut_Primitive21(ACoverageUFunctionReturnOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnAndOutParameterPermutationMatrix setup: required Actor is null");
	}
	int OutInt = 0;
	bool bOutBool = false;
	FString OutLabel;
	int Result = Actor.ReturnAndWritePrimitiveOuts(21, OutInt, bOutBool, OutLabel);
	if (OutInt != 31 || !bOutBool || OutLabel != "PrimitiveOut")
	{
		return -1;
	}
	return Result;
}

int Observe_ReturnOut_PrimitiveZeroBoundary(ACoverageUFunctionReturnOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnAndOutParameterPermutationMatrix setup: required Actor is null");
	}
	int OutInt = -1;
	bool bOutBool = true;
	FString OutLabel = "keep";
	int Result = Actor.ReturnAndWritePrimitiveOuts(0, OutInt, bOutBool, OutLabel);
	if (OutInt != 10 || bOutBool || OutLabel != "PrimitiveOut")
	{
		return -1;
	}
	return Result;
}

bool Observe_ReturnOut_StructLastScore42(ACoverageUFunctionReturnOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnAndOutParameterPermutationMatrix setup: required Actor is null");
	}
	FUFunctionReturnOutPayload OutPayload;
	FVector OutLocation = FVector::ZeroVector;
	int InOutScore = 0;
	FUFunctionReturnOutPayload Returned = Actor.ReturnStructAndWriteMixedOuts(11, OutPayload, OutLocation, InOutScore);
	return Actor.LastScore == 42
		&& Actor.LastLabel == "ReturnPayload"
		&& Returned.Count == 42
		&& Returned.Label == "ReturnPayload"
		&& OutPayload.Count == 31
		&& OutPayload.Label == "OutPayload"
		&& InOutScore == 42
		&& OutLocation.X == 11.0;
}

int Observe_ReturnOut_DefaultScore(ACoverageUFunctionReturnOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnAndOutParameterPermutationMatrix setup: required Actor is null");
	}
	return Actor.LastScore;
}

FString Observe_ReturnOut_DefaultLabel(ACoverageUFunctionReturnOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnAndOutParameterPermutationMatrix setup: required Actor is null");
	}
	return Actor.LastLabel;
}
