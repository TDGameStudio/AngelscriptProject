/**
 * TOptional of a USTRUCT returned set versus empty. C++ reads
 * bSetReturnObserved and the last set Count/Label. Keep those UPROPERTY names.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructOptionalReturnMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructOptionalReturnMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: TOptional<FStruct> return set vs empty.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructOptionalReturnMatrix.
 * @Provenance Oracle: ReturnSetPayload IsSet Count 64 Label OptionalReturn; ReturnEmptyPayload !IsSet.
 * @Provenance Extra: default flags false / Count 0. FixtureIsolated.
 */

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

	/**
	 * Return a set optional payload and record the observed Count/Label.
	 *
	 * @Covers UStruct.UStructOptionalReturnMatrix
	 * @Inputs none
	 * @Return a TOptional set to Count 64 and Label OptionalReturn
	 */
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

	/**
	 * Return an unset optional payload.
	 *
	 * @Covers UStruct.UStructOptionalReturnMatrix
	 * @Inputs none
	 * @Return an unset TOptional
	 */
	UFUNCTION(BlueprintCallable)
	TOptional<FOptionalReturnPayload> ReturnEmptyPayload()
	{
		TOptional<FOptionalReturnPayload> Result;
		bEmptyReturnObserved = !Result.IsSet();
		return Result;
	}

	/**
	 * Observe optional-return flags before any call.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOptionalReturnMatrix
	 * @Inputs an actor that has not called ReturnSetPayload
	 * @Return true when flags are false, Count is 0, and Label is empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool OptionalReturnDefaultEmpty()
	{
		if (bSetReturnObserved)
		{
			return false;
		}
		if (bEmptyReturnObserved)
		{
			return false;
		}
		if (LastSetCount != 0)
		{
			return false;
		}
		return LastSetLabel.Len() == 0;
	}

	/**
	 * Observe a set optional return.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOptionalReturnMatrix
	 * @Inputs ReturnSetPayload()
	 * @Return true when the optional is set to 64/OptionalReturn
	 */
	UFUNCTION()
	bool OptionalReturnSetPayload()
	{
		TOptional<FOptionalReturnPayload> Result = ReturnSetPayload();
		if (!Result.IsSet())
		{
			return false;
		}
		if (!bSetReturnObserved)
		{
			return false;
		}
		if (LastSetCount != 64)
		{
			return false;
		}
		if (LastSetLabel != "OptionalReturn")
		{
			return false;
		}
		return Result.GetValue().Count == 64;
	}

	/**
	 * Observe an unset optional return.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOptionalReturnMatrix
	 * @Inputs ReturnEmptyPayload()
	 * @Return true when the optional is unset and bEmptyReturnObserved is true
	 * @Boundary empty optional
	 */
	UFUNCTION()
	bool OptionalReturnEmptyBoundary()
	{
		TOptional<FOptionalReturnPayload> Result = ReturnEmptyPayload();
		if (Result.IsSet())
		{
			return false;
		}
		return bEmptyReturnObserved;
	}
}
