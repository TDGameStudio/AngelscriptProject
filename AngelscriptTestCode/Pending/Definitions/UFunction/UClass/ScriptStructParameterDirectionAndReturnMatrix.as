/**
 * @version v1
 * @summary AS USTRUCT value, const-ref, out, inout, and return. AcceptValue(Count 37, "Value") is 42. AcceptConstRef(Count 34, "ConstRef") is 42. FillOut writes 42/"OutPayload". MutateInout(10, "Input") returns 42 and.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AS USTRUCT value, const-ref, out, inout, and return. AcceptValue(Count 37, "Value") is 42. AcceptConstRef(Count 34, "ConstRef") is 42. FillOut writes 42/"OutPayload". MutateInout(10, "Input") returns 42 and.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FUFunctionDirectionPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUFunctionStructDirectionActor : AActor
{
	UPROPERTY()
	FUFunctionDirectionPayload LastValue;

	UPROPERTY()
	FUFunctionDirectionPayload LastConstRef;

	UPROPERTY()
	bool bInoutSawOriginal = false;

	/**
	 * Accept a struct by value and write LastValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Payload Struct received by value
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int AcceptValue(FUFunctionDirectionPayload Payload)
	{
		LastValue = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Accept a const struct &in and write LastConstRef.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Payload Struct received as const FUFunctionDirectionPayload&in
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int AcceptConstRef(const FUFunctionDirectionPayload&in Payload)
	{
		LastConstRef = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Fill an &out struct with 42 / OutPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Payload Struct received as FUFunctionDirectionPayload&out
	 * @Inputs empty Payload
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	void FillOut(FUFunctionDirectionPayload&out Payload)
	{
		Payload.Count = 42;
		Payload.Label = "OutPayload";
	}

	/**
	 * Mutate an &inout struct and mark bInoutSawOriginal.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Payload Struct received as FUFunctionDirectionPayload&inout
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int MutateInout(FUFunctionDirectionPayload&inout Payload)
	{
		bInoutSawOriginal = Payload.Count == 10 && Payload.Label == "Input";
		Payload.Count += 19;
		Payload.Label += "|Mutated";
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Return Count 42 Label ReturnPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return Count 42 Label ReturnPayload
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	FUFunctionDirectionPayload ReturnPayload()
	{
		FUFunctionDirectionPayload Payload;
		Payload.Count = 42;
		Payload.Label = "ReturnPayload";
		return Payload;
	}

	/**
	 * Observe AcceptValue of Count 37 Label Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs Count 37 Label Value
	 * @Return 42
	 */
	UFUNCTION()
	int AcceptValueFortyTwo()
	{
		FUFunctionDirectionPayload Payload;
		Payload.Count = 37;
		Payload.Label = "Value";
		return AcceptValue(Payload);
	}

	/**
	 * Observe AcceptConstRef of Count 34 Label ConstRef.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs Count 34 Label ConstRef
	 * @Return 42
	 */
	UFUNCTION()
	int AcceptConstRefFortyTwo()
	{
		FUFunctionDirectionPayload Payload;
		Payload.Count = 34;
		Payload.Label = "ConstRef";
		return AcceptConstRef(Payload);
	}

	/**
	 * Observe AcceptValue of an empty payload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs empty payload
	 * @Return 0
	 * @Boundary empty value
	 */
	UFUNCTION()
	int EmptyValue()
	{
		FUFunctionDirectionPayload Payload;
		return AcceptValue(Payload);
	}

	/**
	 * Observe FillOut destinations.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs empty payload
	 * @Return true when Count 42 Label OutPayload
	 */
	UFUNCTION()
	bool FillOutState()
	{
		FUFunctionDirectionPayload Payload;
		FillOut(Payload);
		if (Payload.Count != 42)
		{
			return false;
		}
		return Payload.Label == "OutPayload";
	}

	/**
	 * Observe MutateInout of Count 10 Label Input.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs Count 10 Label Input
	 * @Return 42 when mutated to 29 / Input|Mutated and bInoutSawOriginal
	 */
	UFUNCTION()
	int MutateInoutState()
	{
		FUFunctionDirectionPayload Payload;
		Payload.Count = 10;
		Payload.Label = "Input";
		int Result = MutateInout(Payload);
		if (!bInoutSawOriginal)
		{
			return -1;
		}
		if (Payload.Count != 29)
		{
			return -1;
		}
		if (Payload.Label != "Input|Mutated")
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe ReturnPayload Count 42 Label ReturnPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnPayload
	 * @Return true when Count 42 Label ReturnPayload
	 */
	UFUNCTION()
	bool ReturnPayloadState()
	{
		FUFunctionDirectionPayload Payload = ReturnPayload();
		if (Payload.Count != 42)
		{
			return false;
		}
		return Payload.Label == "ReturnPayload";
	}

	/**
	 * Observe the default bInoutSawOriginal.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return true when bInoutSawOriginal is false
	 * @Boundary default inout flag
	 */
	UFUNCTION()
	bool DefaultInoutFlag()
	{
		return !bInoutSawOriginal;
	}

	/**
	 * Observe that mutating the input copy does not change LastValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs Count 37 Label Value then mutated local copy
	 * @Return true when LastValue stays Count 37 Label Value
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FUFunctionDirectionPayload First;
		First.Count = 37;
		First.Label = "Value";
		AcceptValue(First);
		First.Count = 0;
		First.Label = "";
		if (LastValue.Count != 37)
		{
			return false;
		}
		return LastValue.Label == "Value";
	}
}
/** @end */
