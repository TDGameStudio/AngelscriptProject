// Theme: Definitions.UFunction. WorldStory: TOptional<int>/USTRUCT set vs empty returns.
// C++: AngelscriptCoverageUFunctionTests.cpp::OptionalReturnReflectionMatrix
// Oracle: ReturnSetInt IsSet 42 and bSetIntObserved true; ReturnEmptyInt unset bEmptyIntObserved true;
// ReturnSetPayload Count 42 Label OptionalPayload; ReturnEmptyPayload unset.
// Extra: default observation flags are false; empty payload Count default 0.
// FixtureIsolated. Runner owns World teardown.

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<int> ReturnSetInt()
	{
		TOptional<int> Result;
		Result.Set(42);
		bSetIntObserved = Result.IsSet() && Result.GetValue() == 42;
		return Result;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<int> ReturnEmptyInt()
	{
		TOptional<int> Result;
		bEmptyIntObserved = !Result.IsSet();
		return Result;
	}

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Optional")
	TOptional<FUFunctionOptionalPayload> ReturnEmptyPayload()
	{
		TOptional<FUFunctionOptionalPayload> Result;
		bEmptyPayloadObserved = !Result.IsSet();
		return Result;
	}
}

bool Observe_OptionalReturn_SetInt(ACoverageUFunctionOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OptionalReturnReflectionMatrix setup: required Actor is null");
	}
	TOptional<int> Result = Actor.ReturnSetInt();
	return Actor.bSetIntObserved && Result.IsSet() && Result.GetValue() == 42;
}

bool Observe_OptionalReturn_EmptyInt(ACoverageUFunctionOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OptionalReturnReflectionMatrix setup: required Actor is null");
	}
	TOptional<int> Result = Actor.ReturnEmptyInt();
	return Actor.bEmptyIntObserved && !Result.IsSet();
}

bool Observe_OptionalReturn_SetPayload(ACoverageUFunctionOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OptionalReturnReflectionMatrix setup: required Actor is null");
	}
	TOptional<FUFunctionOptionalPayload> Result = Actor.ReturnSetPayload();
	return Actor.bSetPayloadObserved
		&& Result.IsSet()
		&& Result.GetValue().Count == 42
		&& Result.GetValue().Label == "OptionalPayload";
}

bool Observe_OptionalReturn_EmptyPayload(ACoverageUFunctionOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OptionalReturnReflectionMatrix setup: required Actor is null");
	}
	TOptional<FUFunctionOptionalPayload> Result = Actor.ReturnEmptyPayload();
	return Actor.bEmptyPayloadObserved && !Result.IsSet();
}

bool Observe_OptionalReturn_DefaultFlagsFalse(ACoverageUFunctionOptionalReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OptionalReturnReflectionMatrix setup: required Actor is null");
	}
	return !Actor.bSetIntObserved
		&& !Actor.bEmptyIntObserved
		&& !Actor.bSetPayloadObserved
		&& !Actor.bEmptyPayloadObserved;
}
