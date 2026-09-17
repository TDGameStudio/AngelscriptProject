/**
 * @version v1
 * @summary Actor handle basics: null by default, valid after assignment, and null again after clearing. The results encode the last observed state of each check.
 * @topic Language
 */
/**
 * @version root
 * @summary Actor handle basics: null by default, valid after assignment, and null again after clearing. The results encode the last observed state of each check.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandleBasicsActor : AActor
{
	UPROPERTY()
	bool TestPassed = false;

	UPROPERTY()
	AActor TargetActor;

	UPROPERTY()
	int NullCheckResult = 0;

	UPROPERTY()
	int IsValidResult = 0;

	/**
	 * Runs the null, assign, valid and clear sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the results record the final state
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test null by default
		if (TargetActor == nullptr)
		{
			NullCheckResult = 1;
		}

		// Test IsValid with nullptr
		if (!IsValid(TargetActor))
		{
			IsValidResult = 1;
		}

		// Assign self
		TargetActor = this;

		// Test non-null after assignment
		if (TargetActor != nullptr)
		{
			NullCheckResult = 2;
		}

		// Test IsValid with valid object
		if (IsValid(TargetActor))
		{
			IsValidResult = 2;
		}

		// Assign back to null
		TargetActor = nullptr;

		// Verify null again
		if (TargetActor == nullptr)
		{
			NullCheckResult = 3;
		}

		TestPassed = (NullCheckResult == 3 && IsValidResult == 2);
	}

	/**
	 * Observe that a locally constructed actor has run no checks.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the target is null, both results are 0 and TestPassed is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleBasicsDefaultEmpty()
	{
		if (TestPassed)
		{
			return false;
		}

		if (TargetActor != nullptr)
		{
			return false;
		}

		if (NullCheckResult != 0)
		{
			return false;
		}

		return IsValidResult == 0;
	}
}
/** @end */
