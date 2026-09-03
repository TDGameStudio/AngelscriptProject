/**
 * A UFUNCTION delegate parameter execute plus reflection. ExerciseDelegateParameter
 * returns 42 (20 + "DelegateLabel".Len() + 9). Unbound AcceptDelegate returns -1.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateParameterReflectionAndRuntimeMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateParameterReflectionAndRuntimeMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory: UFUNCTION delegate parameter execute + reflection.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::DelegateParameterReflectionAndRuntimeMatrix
 * @Provenance Invoke ExerciseDelegateParameter oracle: returns 42 (20 + "DelegateLabel".Len() + 9),
 * @Provenance LastDelegateResult==42, LastDelegateLabel=="DelegateLabel". Unbound AcceptDelegate returns -1.
 * @Provenance Extra: defaults 0/empty; unbound path -1. Keep LastDelegateResult, LastDelegateLabel.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast that computes from a value and a label.
 *
 * @Covers Delegates.Execute
 * @Inputs Value and Label
 * @Return an int from the bound handler
 */
delegate int FCoverageUFunctionComputeDelegate(int Value, const FString&in Label);

UCLASS()
class ACoverageUFunctionDelegateActor : AActor
{
	UPROPERTY()
	int LastDelegateResult = 0;

	UPROPERTY()
	FString LastDelegateLabel;

	/**
	 * Executes Callback with 20 / "DelegateLabel", or -1 when unbound.
	 *
	 * @Covers Delegates.Execute
	 * @Param Callback the unicast to execute
	 * @Inputs Callback
	 * @Return the handler result, or -1 when unbound
	 * @Boundary unbound callback
	 */
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

	/**
	 * Stores Label and returns Value plus Label length plus 9.
	 *
	 * @Covers Delegates.Execute
	 * @Param Value the payload
	 * @Param Label the payload label
	 * @Inputs Value and Label
	 * @Return Value + Label.Len() + 9
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Delegate")
	int ComputeFromDelegate(int Value, FString Label)
	{
		LastDelegateLabel = Label;
		return Value + Label.Len() + 9;
	}

	/**
	 * Binds ComputeFromDelegate and accepts the callback.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Delegate")
	int ExerciseDelegateParameter()
	{
		FCoverageUFunctionComputeDelegate Callback;
		Callback.BindUFunction(this, n"ComputeFromDelegate");
		return AcceptDelegate(Callback);
	}

	/**
	 * Observe the default LastDelegateResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return 0
	 * @Boundary default result
	 */
	UFUNCTION()
	int LastDelegateResultDefaultZero()
	{
		return LastDelegateResult;
	}

	/**
	 * Observe that LastDelegateLabel starts empty.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return true when LastDelegateLabel is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool LastDelegateLabelDefaultEmpty()
	{
		return LastDelegateLabel.Len() == 0;
	}

	/**
	 * Observe that an unbound compute delegate is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an unbound FCoverageUFunctionComputeDelegate
	 * @Return -1 when unbound
	 * @Boundary empty unbound
	 */
	UFUNCTION()
	int UnboundAcceptEmptyBoundary()
	{
		FCoverageUFunctionComputeDelegate Callback;
		if (!Callback.IsBound())
		{
			return -1;
		}
		return 0;
	}
}
