/**
 * @version v1
 * @summary NotBlueprintCallable, BlueprintCallable, BlueprintPure, and CallInEditor+Exec. Value defaults to 7, CallableAdd(3) is 10, PureValue is 7, and EditorExecMethod adds 10. CallableAdd(0) is the empty addend, and a nullptr.
 * @topic Definitions
 */
/**
 * @version root
 * @summary NotBlueprintCallable, BlueprintCallable, BlueprintPure, and CallInEditor+Exec. Value defaults to 7, CallableAdd(3) is 10, PureValue is 7, and EditorExecMethod adds 10. CallableAdd(0) is the empty addend, and a nullptr.
 * @topic Baseline
 */
UCLASS()
class ACoverageMetaUFunctionFlagsActor : AActor
{
	UPROPERTY()
	int Value = 7;

	/**
	 * Hidden increment of Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void; Value increases by 1
	 */
	UFUNCTION(NotBlueprintCallable)
	void BasicMethod()
	{
		Value += 1;
	}

	/**
	 * Add Input to Value without writing it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Input Addend
	 * @Inputs Input
	 * @Return Value + Input
	 */
	UFUNCTION(BlueprintCallable, Category = "Coverage|Functions")
	int CallableAdd(int Input)
	{
		return Value + Input;
	}

	/**
	 * Const getter for Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs Value
	 * @Return the current Value
	 */
	UFUNCTION(BlueprintPure)
	int PureValue() const
	{
		return Value;
	}

	/**
	 * CallInEditor Exec method that adds 10 to Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void; Value increases by 10
	 */
	UFUNCTION(CallInEditor, Exec)
	void EditorExecMethod()
	{
		Value += 10;
	}

	/**
	 * Observe the default Value and CallableAdd(3).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs PureValue() and CallableAdd(3)
	 * @Return true when PureValue is 7, CallableAdd is 10, and Value stays 7
	 */
	UFUNCTION()
	bool NominalDefault()
	{
		if (PureValue() != 7)
		{
			return false;
		}
		if (CallableAdd(3) != 10)
		{
			return false;
		}
		return Value == 7;
	}

	/**
	 * Observe CallableAdd(0) as the empty addend.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CallableAdd(0)
	 * @Return true when the sum equals Value and PureValue
	 * @Boundary zero addend
	 */
	UFUNCTION()
	bool ZeroAddendEmpty()
	{
		if (CallableAdd(0) != Value)
		{
			return false;
		}
		return PureValue() == Value;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageMetaUFunctionFlagsActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageMetaUFunctionFlagsActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe BasicMethod then EditorExecMethod adding 11.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs BasicMethod() then EditorExecMethod()
	 * @Return true when Value increased by 11
	 */
	UFUNCTION()
	bool IncrementBoundary()
	{
		int Before = Value;
		BasicMethod();
		EditorExecMethod();
		if (Value != Before + 11)
		{
			return false;
		}
		return PureValue() == Before + 11;
	}
}
/** @end */
