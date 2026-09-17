/**
 * @version v1
 * @summary A UFUNCTION method that mutates its own object. The observers confirm the mutation persists on the instance it was called on and does not leak to a second instance.
 * @topic Language
 */
/**
 * @version root
 * @summary A UFUNCTION method that mutates its own object. The observers confirm the mutation persists on the instance it was called on and does not leak to a second instance.
 * @topic Baseline
 */
UCLASS()
class UCompilerExecutionCarrier : UObject
{
	UPROPERTY()
	int Score = 41;

	/**
	 * Increments the score and returns the new value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the carrier's Score
	 * @Return 42 after the first call
	 */
	UFUNCTION()
	int IncrementAndGetScore()
	{
		Score += 1;
		return Score;
	}

	/**
	 * Observe that the mutation is returned and persisted.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs IncrementAndGetScore then Score
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool AnnotatedMethodMutatesAndPersists()
	{
		if (IncrementAndGetScore() != 42)
		{
			return false;
		}

		return Score == 42;
	}

	/**
	 * Observe the default state before any call.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when Score is 41
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AnnotatedMethodScoreDefaultsToFortyOne()
	{
		return Score == 41;
	}

	/**
	 * Observe that mutating this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier mutated, compared against a second carrier
	 * @Return true when this carrier reads 42 and the other reads 41
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool AnnotatedMethodInstancesAreIndependent()
	{
		UCompilerExecutionCarrier Other =
			Cast<UCompilerExecutionCarrier>(
				NewObject(GetTransientPackage(), UCompilerExecutionCarrier::StaticClass(), n"CompilerExecutionCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_AnnotatedMethodExecutes setup: NewObject returned null");
		}

		IncrementAndGetScore();

		if (Score != 42)
		{
			return false;
		}

		return Other.Score == 41;
	}
}
/** @end */
