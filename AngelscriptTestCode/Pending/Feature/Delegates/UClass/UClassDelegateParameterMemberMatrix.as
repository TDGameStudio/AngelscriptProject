/**
 * @version v1
 * @summary Delegate members passed by value and const-ref. After BeginPlay, ValueParameterResult 25 (11+"ValueParameter".Len()), ConstRefParameterResult 34, CopiedCallbackResult 25, HandlerInputTotal 39, LastHandlerLabel.
 * @topic Feature
 */
/**
 * @version root
 * @summary Delegate members passed by value and const-ref. After BeginPlay, ValueParameterResult 25 (11+"ValueParameter".Len()), ConstRefParameterResult 34, CopiedCallbackResult 25, HandlerInputTotal 39, LastHandlerLabel.
 * @topic Baseline
 */
/**
 * A unicast that computes from a value and a label.
 *
 * @Covers Delegates.Execute
 * @Inputs Value and Label
 * @Return int
 */
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

	/**
	 * WorldStory: BeginPlay binds StoredCallback, copies it, and consumes by value and const-ref.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ValueParameterResult 25, ConstRefParameterResult 34, CopiedCallbackResult 25
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StoredCallback.BindUFunction(this, n"HandleCallback");
		CopiedCallback = StoredCallback;
		ValueParameterResult = ConsumeCallbackByValue(StoredCallback);
		ConstRefParameterResult = ConsumeCallbackByConstRef(StoredCallback);
		CopiedCallbackResult = ConsumeCallbackByValue(CopiedCallback);
	}

	/**
	 * Execute Callback with 11 / ValueParameter, or -1 when unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Callback Unicast received by value
	 * @Inputs Callback
	 * @Return the handler result, or -1 when unbound
	 * @Boundary unbound callback
	 */
	UFUNCTION(BlueprintCallable)
	int ConsumeCallbackByValue(FUClassPropertyDelegateParameterCallback Callback)
	{
		if (!Callback.IsBound())
		{
			return -1;
		}

		return Callback.Execute(11, "ValueParameter");
	}

	/**
	 * Execute Callback with 17 / ConstRefParameter, or -2 when unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Callback Unicast received as const FUClassPropertyDelegateParameterCallback&in
	 * @Inputs Callback
	 * @Return the handler result, or -2 when unbound
	 * @Boundary unbound const-ref callback
	 */
	UFUNCTION(BlueprintCallable)
	int ConsumeCallbackByConstRef(const FUClassPropertyDelegateParameterCallback&in Callback)
	{
		if (!Callback.IsBound())
		{
			return -2;
		}

		return Callback.Execute(17, "ConstRefParameter");
	}

	/**
	 * Consume an unbound callback by value.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty callback
	 * @Return -1
	 * @Boundary unbound callback
	 */
	UFUNCTION(BlueprintCallable)
	int ExerciseUnboundCallback()
	{
		FUClassPropertyDelegateParameterCallback EmptyCallback;
		return ConsumeCallbackByValue(EmptyCallback);
	}

	/**
	 * Add Value to HandlerInputTotal and return Value + Label.Len().
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Param Label String received by value
	 * @Inputs Value and Label
	 * @Return Value + Label.Len()
	 */
	UFUNCTION()
	int HandleCallback(int Value, FString Label)
	{
		HandlerInputTotal += Value;
		LastHandlerLabel = Label;
		return Value + Label.Len();
	}

	/**
	 * Observe the default ValueParameterResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ValueParameterResult
	 */
	UFUNCTION()
	int ValueParameterResultDefaultZero()
	{
		return ValueParameterResult;
	}

	/**
	 * Observe the default LastHandlerLabel.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when LastHandlerLabel is empty
	 * @Boundary default LastHandlerLabel
	 */
	UFUNCTION()
	bool LastHandlerLabelDefaultEmpty()
	{
		return LastHandlerLabel.Len() == 0;
	}

	/**
	 * Observe an unbound empty callback.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty callback
	 * @Return -1
	 * @Boundary unbound callback
	 */
	UFUNCTION()
	int UnboundCallbackEmptyBoundary()
	{
		FUClassPropertyDelegateParameterCallback EmptyCallback;
		if (!EmptyCallback.IsBound())
		{
			return -1;
		}
		return 0;
	}

	/**
	 * Observe that mutating a string copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original ValueParameter and a mutated copy
	 * @Return true when Original stays ValueParameter
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StringCopyIndependence()
	{
		FString Original = "ValueParameter";
		FString Copy = Original;
		Copy = "ConstRefParameter";
		if (Original != "ValueParameter")
		{
			return false;
		}
		return Copy == "ConstRefParameter";
	}
}
/** @end */
