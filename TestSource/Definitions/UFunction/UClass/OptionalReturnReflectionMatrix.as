/**
 * TOptional<int>/USTRUCT set versus empty returns. ReturnSetInt IsSet 42 and
 * bSetIntObserved true. ReturnEmptyInt unset and bEmptyIntObserved true.
 * ReturnSetPayload Count 42 Label OptionalPayload. ReturnEmptyPayload unset.
 * Default observation flags are false. Empty payload Count default 0.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.OptionalReturnReflectionMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.OptionalReturnReflectionMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: TOptional<int>/USTRUCT set vs empty returns.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::OptionalReturnReflectionMatrix
 * @Provenance Oracle: ReturnSetInt IsSet 42 and bSetIntObserved true; ReturnEmptyInt unset bEmptyIntObserved true;
 * @Provenance ReturnSetPayload Count 42 Label OptionalPayload; ReturnEmptyPayload unset.
 * @Provenance Extra: default observation flags are false; empty payload Count default 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

USTRUCT(BlueprintType)
struct FUFunctionOptionalPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUFunctionOptionalReturnActor : AActor
{
	UPROPERTY()
	bool bSetIntObserved = false;

	UPROPERTY()
	bool bEmptyIntObserved = false;

	UPROPERTY()
	bool bSetPayloadObserved = false;

	UPROPERTY()
	bool bEmptyPayloadObserved = false;

	/**
	 * Return a set TOptional<int> of 42 and mark bSetIntObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return TOptional<int> set to 42
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<int> ReturnSetInt()
	{
		TOptional<int> Result;
		Result.Set(42);
		bSetIntObserved = Result.IsSet() && Result.GetValue() == 42;
		return Result;
	}

	/**
	 * Return an empty TOptional<int> and mark bEmptyIntObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return unset TOptional<int>
	 * @Boundary empty optional
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<int> ReturnEmptyInt()
	{
		TOptional<int> Result;
		bEmptyIntObserved = !Result.IsSet();
		return Result;
	}

	/**
	 * Return a set TOptional payload of Count 42 Label OptionalPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return TOptional<FUFunctionOptionalPayload> set to Count 42 Label OptionalPayload
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<FUFunctionOptionalPayload> ReturnSetPayload()
	{
		FUFunctionOptionalPayload Payload;
		Payload.Count = 42;
		Payload.Label = "OptionalPayload";

		TOptional<FUFunctionOptionalPayload> Result;
		Result.Set(Payload);
		bSetPayloadObserved = Result.IsSet()
			&& Result.GetValue().Count == 42
			&& Result.GetValue().Label == "OptionalPayload";
		return Result;
	}

	/**
	 * Return an empty TOptional payload and mark bEmptyPayloadObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return unset TOptional<FUFunctionOptionalPayload>
	 * @Boundary empty payload optional
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<FUFunctionOptionalPayload> ReturnEmptyPayload()
	{
		TOptional<FUFunctionOptionalPayload> Result;
		bEmptyPayloadObserved = !Result.IsSet();
		return Result;
	}

	/**
	 * Observe ReturnSetInt IsSet 42 and bSetIntObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnSetInt
	 * @Return true when IsSet 42 and bSetIntObserved
	 */
	UFUNCTION()
	bool SetInt()
	{
		TOptional<int> Result = ReturnSetInt();
		if (!bSetIntObserved)
		{
			return false;
		}
		if (!Result.IsSet())
		{
			return false;
		}
		return Result.GetValue() == 42;
	}

	/**
	 * Observe ReturnEmptyInt unset and bEmptyIntObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnEmptyInt
	 * @Return true when unset and bEmptyIntObserved
	 * @Boundary empty int optional
	 */
	UFUNCTION()
	bool EmptyInt()
	{
		TOptional<int> Result = ReturnEmptyInt();
		if (!bEmptyIntObserved)
		{
			return false;
		}
		return !Result.IsSet();
	}

	/**
	 * Observe ReturnSetPayload Count 42 Label OptionalPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnSetPayload
	 * @Return true when set Count 42 Label OptionalPayload and bSetPayloadObserved
	 */
	UFUNCTION()
	bool SetPayload()
	{
		TOptional<FUFunctionOptionalPayload> Result = ReturnSetPayload();
		if (!bSetPayloadObserved)
		{
			return false;
		}
		if (!Result.IsSet())
		{
			return false;
		}
		if (Result.GetValue().Count != 42)
		{
			return false;
		}
		return Result.GetValue().Label == "OptionalPayload";
	}

	/**
	 * Observe ReturnEmptyPayload unset and bEmptyPayloadObserved.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnEmptyPayload
	 * @Return true when unset and bEmptyPayloadObserved
	 * @Boundary empty payload optional
	 */
	UFUNCTION()
	bool EmptyPayload()
	{
		TOptional<FUFunctionOptionalPayload> Result = ReturnEmptyPayload();
		if (!bEmptyPayloadObserved)
		{
			return false;
		}
		return !Result.IsSet();
	}

	/**
	 * Observe default observation flags.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs a freshly constructed actor
	 * @Return true when all four flags are false
	 * @Boundary default flags
	 */
	UFUNCTION()
	bool DefaultFlagsFalse()
	{
		if (bSetIntObserved)
		{
			return false;
		}
		if (bEmptyIntObserved)
		{
			return false;
		}
		if (bSetPayloadObserved)
		{
			return false;
		}
		return !bEmptyPayloadObserved;
	}
}
