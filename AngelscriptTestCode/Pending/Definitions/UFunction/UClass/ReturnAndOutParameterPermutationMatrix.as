/**
 * @version v1
 * @summary Return plus primitive/struct out/inout permutation. ReturnAndWritePrimitiveOuts(21) is 65 OutInt 31 bOutBool true OutLabel PrimitiveOut. ReturnStructAndWriteMixedOuts(11, InOutScore 0) LastScore 42 LastLabel.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Return plus primitive/struct out/inout permutation. ReturnAndWritePrimitiveOuts(21) is 65 OutInt 31 bOutBool true OutLabel PrimitiveOut. ReturnStructAndWriteMixedOuts(11, InOutScore 0) LastScore 42 LastLabel.
 * @topic Baseline
 */
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

	/**
	 * Return LastScore and write primitive out int, bool, and label.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param BaseValue Integer received by value
	 * @Param OutInt Integer received as int&out
	 * @Param bOutBool Bool received as bool&out
	 * @Param OutLabel String received as FString&out
	 * @Inputs BaseValue and empty out destinations
	 * @Return LastScore
	 */
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

	/**
	 * Return a payload and write mixed out payload, location, and inout score.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param BaseValue Integer received by value
	 * @Param OutPayload Struct received as FUFunctionReturnOutPayload&out
	 * @Param OutLocation Vector received as FVector&out
	 * @Param InOutScore Integer received as int&inout
	 * @Inputs BaseValue, empty OutPayload, ZeroVector, InOutScore
	 * @Return ReturnPayload of Count InOutScore Label ReturnPayload
	 */
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

	/**
	 * Observe ReturnAndWritePrimitiveOuts of 21.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 21
	 * @Return 65 when OutInt 31 bOutBool true OutLabel PrimitiveOut
	 */
	UFUNCTION()
	int PrimitiveTwentyOne()
	{
		int OutInt = 0;
		bool bOutBool = false;
		FString OutLabel;
		int Result = ReturnAndWritePrimitiveOuts(21, OutInt, bOutBool, OutLabel);
		if (OutInt != 31)
		{
			return -1;
		}
		if (!bOutBool)
		{
			return -1;
		}
		if (OutLabel != "PrimitiveOut")
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe ReturnAndWritePrimitiveOuts of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 0
	 * @Return LastScore when OutInt 10 bOutBool false OutLabel PrimitiveOut
	 * @Boundary BaseValue 0
	 */
	UFUNCTION()
	int PrimitiveZeroBoundary()
	{
		int OutInt = -1;
		bool bOutBool = true;
		FString OutLabel = "keep";
		int Result = ReturnAndWritePrimitiveOuts(0, OutInt, bOutBool, OutLabel);
		if (OutInt != 10)
		{
			return -1;
		}
		if (bOutBool)
		{
			return -1;
		}
		if (OutLabel != "PrimitiveOut")
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe ReturnStructAndWriteMixedOuts of 11 and InOutScore 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs 11, InOutScore 0
	 * @Return true when LastScore 42 LastLabel ReturnPayload and matching out members
	 */
	UFUNCTION()
	bool StructLastScoreFortyTwo()
	{
		FUFunctionReturnOutPayload OutPayload;
		FVector OutLocation = FVector::ZeroVector;
		int InOutScore = 0;
		FUFunctionReturnOutPayload Returned = ReturnStructAndWriteMixedOuts(11, OutPayload, OutLocation, InOutScore);
		if (LastScore != 42)
		{
			return false;
		}
		if (LastLabel != "ReturnPayload")
		{
			return false;
		}
		if (Returned.Count != 42)
		{
			return false;
		}
		if (Returned.Label != "ReturnPayload")
		{
			return false;
		}
		if (OutPayload.Count != 31)
		{
			return false;
		}
		if (OutPayload.Label != "OutPayload")
		{
			return false;
		}
		if (InOutScore != 42)
		{
			return false;
		}
		return OutLocation.X == 11.0;
	}

	/**
	 * Observe the default LastScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastScore
	 */
	UFUNCTION()
	int DefaultScore()
	{
		return LastScore;
	}

	/**
	 * Observe the default LastLabel.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return the empty LastLabel
	 * @Boundary default LastLabel
	 */
	UFUNCTION()
	FString DefaultLabel()
	{
		return LastLabel;
	}
}
/** @end */
