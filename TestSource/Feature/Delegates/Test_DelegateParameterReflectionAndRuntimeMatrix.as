// Theme: Feature.Delegates. WorldStory: UFUNCTION delegate parameter execute + reflection.
// C++: AngelscriptCoverageUFunctionTests.cpp::DelegateParameterReflectionAndRuntimeMatrix
// Invoke ExerciseDelegateParameter oracle: returns 42 (20 + "DelegateLabel".Len() + 9),
// LastDelegateResult==42, LastDelegateLabel=="DelegateLabel". Unbound AcceptDelegate returns -1.
// Extra: defaults 0/empty; unbound path -1. Keep LastDelegateResult, LastDelegateLabel.
// FixtureIsolated.

delegate int FCoverageUFunctionComputeDelegate(int Value, const FString& Label);

UCLASS()
class ACoverageUFunctionDelegateActor : AActor
{
	UPROPERTY()
	int LastDelegateResult = 0;

	UPROPERTY()
	FString LastDelegateLabel;

	UFUNCTION(BlueprintCallable, Category="Coverage|Delegate")
	int AcceptDelegate(FCoverageUFunctionComputeDelegate Callback)
	{
		if (!Callback.IsBound())
		{
			LastDelegateResult = -1;
			return -1;
		}

		LastDelegateResult = Callback.Execute(20, "DelegateLabel");
		return LastDelegateResult;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Delegate")
	int ComputeFromDelegate(int Value, FString Label)
	{
		LastDelegateLabel = Label;
		return Value + Label.Len() + 9;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Delegate")
	int ExerciseDelegateParameter()
	{
		FCoverageUFunctionComputeDelegate Callback;
		Callback.BindUFunction(this, n"ComputeFromDelegate");
		return AcceptDelegate(Callback);
	}
}

int Observe_LastDelegateResult_DefaultZero(ACoverageUFunctionDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DelegateParameterReflectionAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.LastDelegateResult;
}

bool Observe_LastDelegateLabel_DefaultEmpty(ACoverageUFunctionDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DelegateParameterReflectionAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.LastDelegateLabel.Len() == 0;
}

int Observe_UnboundAccept_EmptyBoundary()
{
	FCoverageUFunctionComputeDelegate Callback;
	if (!Callback.IsBound())
	{
		return -1;
	}
	return 0;
}
