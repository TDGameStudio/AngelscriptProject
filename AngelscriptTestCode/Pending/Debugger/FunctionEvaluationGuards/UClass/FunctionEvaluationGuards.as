/**
 * @version v1
 * @summary A debugger marker probe: a getter that counts each evaluation and a method that requires an argument and is therefore never auto-evaluated. C++ reads the counter through reflection to tell the two apart.
 * @topic Debugger
 */
/**
 * @version root
 * @summary A debugger marker probe: a getter that counts each evaluation and a method that requires an argument and is therefore never auto-evaluated. C++ reads the counter through reflection to tell the two apart.
 * @topic Baseline
 */
UCLASS()
class UDebuggerValueGuardProbe : UObject
{
	UPROPERTY()
	int EvalCount = 0;

	/**
	 * A getter that records every evaluation it receives.
	 *
	 * @Covers FunctionEvaluationGuards.EvaluationGuards
	 * @Inputs none
	 * @Return 42 after incrementing the counter
	 */
	UFUNCTION()
	int GetValue()
	{
		EvalCount += 1;
		return 42;
	}

	/**
	 * A method taking an argument, so the debugger must not auto-evaluate it.
	 *
	 * @Covers FunctionEvaluationGuards.EvaluationGuards
	 * @Inputs a value to echo
	 * @Return the value after adding 100 to the counter
	 * @Param Value the echoed argument
	 */
	UFUNCTION()
	int NeedsArg(int Value)
	{
		EvalCount += 100;
		return Value;
	}

	/**
	 * Observe that the evaluation counter starts at zero.
	 *
	 * @Kind Observe
	 * @Covers FunctionEvaluationGuards.EvaluationGuards
	 * @Inputs a freshly constructed probe
	 * @Return true when EvalCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool EvaluationCountStartsAtZero()
	{
		return EvalCount == 0;
	}

	/**
	 * Observe that the getter increments by one on each call.
	 *
	 * @Kind Observe
	 * @Covers FunctionEvaluationGuards.EvaluationGuards
	 * @Inputs GetValue() called twice
	 * @Return true when the counter reads 2 and the value is 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool GetValueIncrementsOncePerCall()
	{
		if (GetValue() != 42)
		{
			return false;
		}

		GetValue();
		return EvalCount == 2;
	}

	/**
	 * Observe that the argument-taking method adds a hundred.
	 *
	 * @Kind Observe
	 * @Covers FunctionEvaluationGuards.EvaluationGuards
	 * @Inputs NeedsArg(7)
	 * @Return true when the counter reads 100 and the argument is echoed
	 * @Boundary argument required
	 */
	UFUNCTION()
	bool NeedsArgAddsHundred()
	{
		if (NeedsArg(7) != 7)
		{
			return false;
		}

		return EvalCount == 100;
	}
}
/** @end */
