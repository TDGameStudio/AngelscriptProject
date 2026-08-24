// Theme: Definitions.UFunction. Positive: global UFUNCTION struct/array/out/return matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::StaticGlobalComplexParameterMatrix
// Oracle: StaticScorePayload(live, Count=10, "Payload", {7,8,9}) == 42;
// StaticFillPayload live writes Count 17 Label GlobalPayload OutScore 30;
// StaticReturnPayload(live, 42) Count 42 Label ReturnedGlobal.
// Extra: null world + empty payload/array scores 0; fill with null writes Count -17 OutScore -4.
// DefaultSafe.

USTRUCT(BlueprintType)
struct FUFunctionGlobalPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UFUNCTION(BlueprintCallable, Category="Coverage|GlobalComplex")
int StaticScorePayload(UObject WorldContextObject, const FUFunctionGlobalPayload&in Payload, const TArray<int>&in Values)
{
	int Sum = 0;
	for (int Value : Values)
	{
		Sum += Value;
	}

	return (WorldContextObject != nullptr ? 1 : 0) + Payload.Count + Payload.Label.Len() + Sum;
}

UFUNCTION(BlueprintCallable, Category="Coverage|GlobalComplex")
void StaticFillPayload(UObject WorldContextObject, FUFunctionGlobalPayload&out OutPayload, int&out OutScore)
{
	OutPayload.Count = WorldContextObject != nullptr ? 17 : -17;
	OutPayload.Label = "GlobalPayload";
	OutScore = OutPayload.Count + OutPayload.Label.Len();
}

UFUNCTION(BlueprintPure, Category="Coverage|GlobalComplex")
FUFunctionGlobalPayload StaticReturnPayload(UObject WorldContextObject, int Value)
{
	FUFunctionGlobalPayload Payload;
	Payload.Count = WorldContextObject != nullptr ? Value : -Value;
	Payload.Label = "ReturnedGlobal";
	return Payload;
}

int Observe_StaticComplex_ScoreNominal(UObject WorldContextObject)
{
	FUFunctionGlobalPayload Payload;
	Payload.Count = 10;
	Payload.Label = "Payload";
	TArray<int> Values;
	Values.Add(7);
	Values.Add(8);
	Values.Add(9);
	return StaticScorePayload(WorldContextObject, Payload, Values);
}

int Observe_StaticComplex_ScoreEmptyNull()
{
	FUFunctionGlobalPayload Payload;
	TArray<int> Values;
	return StaticScorePayload(nullptr, Payload, Values);
}

bool Observe_StaticComplex_FillLive(UObject WorldContextObject)
{
	FUFunctionGlobalPayload OutPayload;
	int OutScore = 0;
	StaticFillPayload(WorldContextObject, OutPayload, OutScore);
	return OutPayload.Count == 17 && OutPayload.Label == "GlobalPayload" && OutScore == 30;
}

bool Observe_StaticComplex_FillNullWorld()
{
	FUFunctionGlobalPayload OutPayload;
	int OutScore = 0;
	StaticFillPayload(nullptr, OutPayload, OutScore);
	return OutPayload.Count == -17 && OutPayload.Label == "GlobalPayload" && OutScore == -4;
}

bool Observe_StaticComplex_ReturnLive(UObject WorldContextObject)
{
	FUFunctionGlobalPayload Payload = StaticReturnPayload(WorldContextObject, 42);
	return Payload.Count == 42 && Payload.Label == "ReturnedGlobal";
}

bool Observe_StaticComplex_ReturnNullNegatesValue()
{
	FUFunctionGlobalPayload Payload = StaticReturnPayload(nullptr, 42);
	return Payload.Count == -42 && Payload.Label == "ReturnedGlobal";
}
