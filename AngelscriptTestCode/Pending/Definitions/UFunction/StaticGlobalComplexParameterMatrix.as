/**
 * @version v1
 * @summary Global UFUNCTION struct, array, out, and return matrix. Scoring a live payload with Count 10, "Payload", and {7,8,9} yields 42. Filling a live payload writes Count 17, Label GlobalPayload, and OutScore 30. Returning a.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Global UFUNCTION struct, array, out, and return matrix. Scoring a live payload with Count 10, "Payload", and {7,8,9} yields 42. Filling a live payload writes Count 17, Label GlobalPayload, and OutScore 30. Returning a.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FUFunctionGlobalPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

/**
 * Score a payload plus array, gated by whether WorldContextObject is live.
 *
 * @Kind Observe
 * @Covers UFunction.Parameter
 * @Param WorldContextObject World context used as a live-handle gate
 * @Param Payload Input payload received as const FUFunctionGlobalPayload&in
 * @Param Values Input integers received as const TArray<int>&in
 * @Inputs WorldContextObject, Payload, and Values
 * @Return 1 or 0 for live context, plus Count, Label length, and the array sum
 */
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

/**
 * Fill an out payload and out score from the world-context gate.
 *
 * @Kind Observe
 * @Covers UFunction.Parameter
 * @Param WorldContextObject World context used as a live-handle gate
 * @Param OutPayload Destination received as FUFunctionGlobalPayload&out
 * @Param OutScore Destination received as int&out
 * @Inputs WorldContextObject plus empty out slots
 * @Return void; OutPayload.Count is 17 or -17 and OutScore is Count plus label length
 */
UFUNCTION(BlueprintCallable, Category="Coverage|GlobalComplex")
void StaticFillPayload(UObject WorldContextObject, FUFunctionGlobalPayload&out OutPayload, int&out OutScore)
{
	OutPayload.Count = WorldContextObject != nullptr ? 17 : -17;
	OutPayload.Label = "GlobalPayload";
	OutScore = OutPayload.Count + OutPayload.Label.Len();
}

/**
 * Return a payload whose Count is Value or -Value depending on the context.
 *
 * @Kind Observe
 * @Covers UFunction.Return
 * @Param WorldContextObject World context used as a live-handle gate
 * @Param Value Count written when the context is live; negated when it is not
 * @Inputs WorldContextObject and Value
 * @Return a payload with Label ReturnedGlobal
 */
UFUNCTION(BlueprintPure, Category="Coverage|GlobalComplex")
FUFunctionGlobalPayload StaticReturnPayload(UObject WorldContextObject, int Value)
{
	FUFunctionGlobalPayload Payload;
	Payload.Count = WorldContextObject != nullptr ? Value : -Value;
	Payload.Label = "ReturnedGlobal";
	return Payload;
}

namespace UFunctionTest
{
	/**
	 * Observe scoring a live payload of Count 10, "Payload", and {7,8,9}.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param WorldContextObject Live world context
	 * @Inputs StaticScorePayload with Count 10, Label Payload, values 7 8 9
	 * @Return 42 when the context is live
	 */
	UFUNCTION()
	int ScoreLivePayload(UObject WorldContextObject)
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

	/**
	 * Observe scoring an empty payload against a null world context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs StaticScorePayload(nullptr, empty payload, empty array)
	 * @Return 0
	 * @Boundary null world and empty payload
	 */
	UFUNCTION()
	int ScoreEmptyNullWorld()
	{
		FUFunctionGlobalPayload Payload;
		TArray<int> Values;
		return StaticScorePayload(nullptr, Payload, Values);
	}

	/**
	 * Observe filling a payload against a live world context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param WorldContextObject Live world context
	 * @Inputs StaticFillPayload on empty out slots
	 * @Return true when Count is 17, Label is GlobalPayload, and OutScore is 30
	 */
	UFUNCTION()
	bool FillLivePayload(UObject WorldContextObject)
	{
		FUFunctionGlobalPayload OutPayload;
		int OutScore = 0;
		StaticFillPayload(WorldContextObject, OutPayload, OutScore);
		if (OutPayload.Count != 17)
		{
			return false;
		}
		if (OutPayload.Label != "GlobalPayload")
		{
			return false;
		}
		return OutScore == 30;
	}

	/**
	 * Observe filling a payload against a null world context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs StaticFillPayload(nullptr, ...)
	 * @Return true when Count is -17, Label is GlobalPayload, and OutScore is -4
	 * @Boundary null world context
	 */
	UFUNCTION()
	bool FillNullWorld()
	{
		FUFunctionGlobalPayload OutPayload;
		int OutScore = 0;
		StaticFillPayload(nullptr, OutPayload, OutScore);
		if (OutPayload.Count != -17)
		{
			return false;
		}
		if (OutPayload.Label != "GlobalPayload")
		{
			return false;
		}
		return OutScore == -4;
	}

	/**
	 * Observe returning a payload against a live world context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param WorldContextObject Live world context
	 * @Inputs StaticReturnPayload(WorldContextObject, 42)
	 * @Return true when Count is 42 and Label is ReturnedGlobal
	 */
	UFUNCTION()
	bool ReturnLivePayload(UObject WorldContextObject)
	{
		FUFunctionGlobalPayload Payload = StaticReturnPayload(WorldContextObject, 42);
		if (Payload.Count != 42)
		{
			return false;
		}
		return Payload.Label == "ReturnedGlobal";
	}

	/**
	 * Observe that a null world context negates the returned Count.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs StaticReturnPayload(nullptr, 42)
	 * @Return true when Count is -42 and Label is ReturnedGlobal
	 * @Boundary null world context
	 */
	UFUNCTION()
	bool ReturnNullNegatesValue()
	{
		FUFunctionGlobalPayload Payload = StaticReturnPayload(nullptr, 42);
		if (Payload.Count != -42)
		{
			return false;
		}
		return Payload.Label == "ReturnedGlobal";
	}
}
/** @end */
