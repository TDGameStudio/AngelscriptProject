// Theme: Feature.Delegates. WorldStory: delegate members passed by value and const-ref.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateParameterMemberMatrix
// Spawn + BeginPlay oracle: ValueParameterResult 25 (11+"ValueParameter".Len()),
// ConstRefParameterResult 34, CopiedCallbackResult 25, HandlerInputTotal 39,
// LastHandlerLabel "ValueParameter" (last by-value execute). ExerciseUnboundCallback returns -1.
// Extra: defaults 0/empty; empty unbound callback returns -1. Keep *Result names.
// FixtureIsolated.

delegate int FUClassPropertyDelegateParameterCallback(int Value, FString Label);

UCLASS()
class ACoverageUClassDelegateParameterActor : AActor
{
	UPROPERTY()
	FUClassPropertyDelegateParameterCallback StoredCallback;

	UPROPERTY()
	FUClassPropertyDelegateParameterCallback CopiedCallback;

	UPROPERTY()
	int ValueParameterResult = 0;

	UPROPERTY()
	int ConstRefParameterResult = 0;

	UPROPERTY()
	int CopiedCallbackResult = 0;

	UPROPERTY()
	int HandlerInputTotal = 0;

	UPROPERTY()
	FString LastHandlerLabel;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StoredCallback.BindUFunction(this, n"HandleCallback");
		CopiedCallback = StoredCallback;
		ValueParameterResult = ConsumeCallbackByValue(StoredCallback);
		ConstRefParameterResult = ConsumeCallbackByConstRef(StoredCallback);
		CopiedCallbackResult = ConsumeCallbackByValue(CopiedCallback);
	}

	UFUNCTION(BlueprintCallable)
	int ConsumeCallbackByValue(FUClassPropertyDelegateParameterCallback Callback)
	{
		if (!Callback.IsBound())
		{
			return -1;
		}

		return Callback.Execute(11, "ValueParameter");
	}

	UFUNCTION(BlueprintCallable)
	int ConsumeCallbackByConstRef(const FUClassPropertyDelegateParameterCallback&in Callback)
	{
		if (!Callback.IsBound())
		{
			return -2;
		}

		return Callback.Execute(17, "ConstRefParameter");
	}

	UFUNCTION(BlueprintCallable)
	int ExerciseUnboundCallback()
	{
		FUClassPropertyDelegateParameterCallback EmptyCallback;
		return ConsumeCallbackByValue(EmptyCallback);
	}

	UFUNCTION()
	int HandleCallback(int Value, FString Label)
	{
		HandlerInputTotal += Value;
		LastHandlerLabel = Label;
		return Value + Label.Len();
	}
}

int Observe_ValueParameterResult_DefaultZero(ACoverageUClassDelegateParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateParameterMemberMatrix setup: required Actor is null");
	}
	return Actor.ValueParameterResult;
}

bool Observe_LastHandlerLabel_DefaultEmpty(ACoverageUClassDelegateParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateParameterMemberMatrix setup: required Actor is null");
	}
	return Actor.LastHandlerLabel.Len() == 0;
}

int Observe_UnboundCallback_EmptyBoundary()
{
	FUClassPropertyDelegateParameterCallback EmptyCallback;
	if (!EmptyCallback.IsBound())
	{
		return -1;
	}
	return 0;
}

bool Observe_String_CopyIndependence()
{
	FString Original = "ValueParameter";
	FString Copy = Original;
	Copy = "ConstRefParameter";
	return Original == "ValueParameter" && Copy == "ConstRefParameter";
}
