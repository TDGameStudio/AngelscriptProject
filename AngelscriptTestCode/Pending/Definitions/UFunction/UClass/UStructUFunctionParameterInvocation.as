/**
 * @version v1
 * @summary USTRUCT UFUNCTION value, const-ref, out, and inout parameters. Incoming 10 writes LastValue 11/"Incoming_Value". Borrowed 20 writes LastConstRef 22/"Borrowed_Ref". FillStructOut writes 55/"OutValue". MutateStructInout.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT UFUNCTION value, const-ref, out, and inout parameters. Incoming 10 writes LastValue 11/"Incoming_Value". Borrowed 20 writes LastConstRef 22/"Borrowed_Ref". FillStructOut writes 55/"OutValue". MutateStructInout.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FInvokedStructParam
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructUFunctionParamActor : AActor
{
	UPROPERTY()
	FInvokedStructParam LastValue;

	UPROPERTY()
	FInvokedStructParam LastConstRef;

	UPROPERTY()
	FInvokedStructParam LastOut;

	UPROPERTY()
	FInvokedStructParam LastInout;

	/**
	 * Accept a struct by value and write LastValue as Count+1 / Label+"_Value".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Param Struct received by value
	 * @Inputs Param
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptStructValue(FInvokedStructParam Param)
	{
		LastValue.Count = Param.Count + 1;
		LastValue.Label = Param.Label + "_Value";
	}

	/**
	 * Accept a const struct &in and write LastConstRef as Count+2 / Label+"_Ref".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Param Struct received as const FInvokedStructParam&in
	 * @Inputs Param
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptStructConstRef(const FInvokedStructParam&in Param)
	{
		LastConstRef.Count = Param.Count + 2;
		LastConstRef.Label = Param.Label + "_Ref";
	}

	/**
	 * Fill an &out struct with 55 / "OutValue".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Param Destination received as FInvokedStructParam&out
	 * @Inputs an empty out struct
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructOut(FInvokedStructParam&out Param)
	{
		Param.Count = 55;
		Param.Label = "OutValue";
		LastOut = Param;
	}

	/**
	 * Mutate an &inout struct by adding 3 and appending "_Inout".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Param Struct received as FInvokedStructParam&inout
	 * @Inputs Param
	 * @Return Param.Count after mutation
	 */
	UFUNCTION(BlueprintCallable)
	int MutateStructInout(FInvokedStructParam&inout Param)
	{
		Param.Count += 3;
		Param.Label += "_Inout";
		LastInout = Param;
		return Param.Count;
	}

	/**
	 * Observe the default Count 0 / empty Label of FInvokedStructParam.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a default-constructed FInvokedStructParam
	 * @Return true when Count is 0 and Label is empty
	 * @Boundary default struct
	 */
	UFUNCTION()
	bool InvokedStructParamEmptyDefault()
	{
		FInvokedStructParam Param;
		if (Param.Count != 0)
		{
			return false;
		}
		return Param.Label == "";
	}

	/**
	 * Observe AcceptStructValue of Count 10 / "Incoming".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptStructValue of Count 10 Label Incoming
	 * @Return true when LastValue is 11 / Incoming_Value
	 */
	UFUNCTION()
	bool AcceptStructValueIncoming()
	{
		FInvokedStructParam Param;
		Param.Count = 10;
		Param.Label = "Incoming";
		AcceptStructValue(Param);
		if (LastValue.Count != 11)
		{
			return false;
		}
		return LastValue.Label == "Incoming_Value";
	}

	/**
	 * Observe that AcceptStructValue does not write the caller's copy.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptStructValue of a copied Incoming struct
	 * @Return true when the copy stays 10 / Incoming and LastValue is 11
	 */
	UFUNCTION()
	bool AcceptStructValueCopyIndependence()
	{
		FInvokedStructParam First;
		First.Count = 10;
		First.Label = "Incoming";
		FInvokedStructParam Second = First;
		AcceptStructValue(First);
		if (Second.Count != 10)
		{
			return false;
		}
		if (Second.Label != "Incoming")
		{
			return false;
		}
		if (First.Count != 10)
		{
			return false;
		}
		if (LastValue.Count != 11)
		{
			return false;
		}
		return LastValue.Label == "Incoming_Value";
	}

	/**
	 * Observe AcceptStructConstRef of Count 20 / "Borrowed".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptStructConstRef of Count 20 Label Borrowed
	 * @Return true when LastConstRef is 22 / Borrowed_Ref
	 */
	UFUNCTION()
	bool AcceptStructConstRefBorrowed()
	{
		FInvokedStructParam Param;
		Param.Count = 20;
		Param.Label = "Borrowed";
		AcceptStructConstRef(Param);
		if (LastConstRef.Count != 22)
		{
			return false;
		}
		return LastConstRef.Label == "Borrowed_Ref";
	}

	/**
	 * Observe FillStructOut writing 55 / "OutValue".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillStructOut on an empty struct
	 * @Return true when Param and LastOut are 55 / OutValue
	 */
	UFUNCTION()
	bool FillStructOutWritesFiftyFive()
	{
		FInvokedStructParam Param;
		FillStructOut(Param);
		if (Param.Count != 55)
		{
			return false;
		}
		if (Param.Label != "OutValue")
		{
			return false;
		}
		if (LastOut.Count != 55)
		{
			return false;
		}
		return LastOut.Label == "OutValue";
	}

	/**
	 * Observe MutateStructInout of Count 70 / "Mutable" returning 73.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateStructInout of Count 70 Label Mutable
	 * @Return 73
	 */
	UFUNCTION()
	int MutateStructInoutReturnsSeventyThree()
	{
		FInvokedStructParam Param;
		Param.Count = 70;
		Param.Label = "Mutable";
		return MutateStructInout(Param);
	}

	/**
	 * Observe MutateStructInout fields after Count 70 / "Mutable".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateStructInout of Count 70 Label Mutable
	 * @Return true when Result, Param, and LastInout are 73 / Mutable_Inout
	 */
	UFUNCTION()
	bool MutateStructInoutFields()
	{
		FInvokedStructParam Param;
		Param.Count = 70;
		Param.Label = "Mutable";
		int Result = MutateStructInout(Param);
		if (Result != 73)
		{
			return false;
		}
		if (Param.Count != 73)
		{
			return false;
		}
		if (Param.Label != "Mutable_Inout")
		{
			return false;
		}
		if (LastInout.Count != 73)
		{
			return false;
		}
		return LastInout.Label == "Mutable_Inout";
	}

	/**
	 * Observe MutateStructInout at the zero/empty boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateStructInout of a default struct
	 * @Return true when Result and Count are 3 and Label is _Inout
	 * @Boundary default struct
	 */
	UFUNCTION()
	bool MutateStructInoutZeroBoundary()
	{
		FInvokedStructParam Param;
		int Result = MutateStructInout(Param);
		if (Result != 3)
		{
			return false;
		}
		if (Param.Count != 3)
		{
			return false;
		}
		return Param.Label == "_Inout";
	}
}
/** @end */
