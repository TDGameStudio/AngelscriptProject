/**
 * @version v1
 * @summary A const recursive Factorial UFUNCTION. Factorial(5) is 120. Factorial(0) and Factorial(1) are the empty base, a nullptr actor is the empty handle, and Factorial(2) is 2.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A const recursive Factorial UFUNCTION. Factorial(5) is 120. Factorial(0) and Factorial(1) are the empty base, a nullptr actor is the empty handle, and Factorial(2) is 2.
 * @topic Baseline
 */
UCLASS()
class ACoverageMetaUFunctionRecursionActor : AActor
{
	/**
	 * Const recursive factorial.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Value whose factorial is computed
	 * @Inputs Value
	 * @Return 1 when Value <= 1, otherwise Value * Factorial(Value - 1)
	 */
	UFUNCTION(BlueprintCallable)
	int Factorial(int Value) const
	{
		if (Value <= 1)
		{
			return 1;
		}

		return Value * Factorial(Value - 1);
	}

	/**
	 * Observe Factorial(5).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs Factorial(5)
	 * @Return true when the result is 120
	 */
	UFUNCTION()
	bool FactorialFiveIsOneHundredTwenty()
	{
		return Factorial(5) == 120;
	}

	/**
	 * Observe the empty base cases Factorial(0) and Factorial(1).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs Factorial(0) and Factorial(1)
	 * @Return true when both results are 1
	 * @Boundary empty base
	 */
	UFUNCTION()
	bool FactorialEmptyBase()
	{
		if (Factorial(0) != 1)
		{
			return false;
		}
		return Factorial(1) == 1;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageMetaUFunctionRecursionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageMetaUFunctionRecursionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe the first recursive boundary Factorial(2) and Factorial(3).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs Factorial(2) and Factorial(3)
	 * @Return true when the results are 2 and 6
	 * @Boundary first recursive values
	 */
	UFUNCTION()
	bool FactorialFirstRecursiveBoundary()
	{
		if (Factorial(2) != 2)
		{
			return false;
		}
		return Factorial(3) == 6;
	}
}
/** @end */
