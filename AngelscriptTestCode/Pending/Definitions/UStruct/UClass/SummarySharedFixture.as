/**
 * @version v1
 * @summary Preprocessor summary shared fixture: one enum, one delegate, one class, one function, and two properties. C++ counts those summary rows. Keep GetAmount, SharedValue, and ESummaryState.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Preprocessor summary shared fixture: one enum, one delegate, one class, one function, and two properties. C++ counts those summary rows. Keep GetAmount, SharedValue, and ESummaryState.
 * @topic Baseline
 */
UENUM()
enum ESummaryState
{
	Idle,
	Active
}

/**
 * A summary-counted delegate with a float return.
 *
 * @Covers UStruct.SummarySharedFixture
 * @Inputs none
 * @Return a float
 */
delegate float FSummaryDelegate();

UCLASS()
class USummaryShared : UObject
{
	/**
	 * The amount counted as the module's one function.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummarySharedFixture
	 * @Inputs none
	 * @Return 3.0
	 */
	UFUNCTION()
	float GetAmount()
	{
		return 3.0;
	}

	UPROPERTY()
	int SharedValue;

	/**
	 * Observe GetAmount on this shared object.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummarySharedFixture
	 * @Inputs this shared object
	 * @Return 3.0
	 */
	UFUNCTION()
	float SummarySharedGetAmountNominal()
	{
		return GetAmount();
	}

	/**
	 * Observe the default SharedValue.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummarySharedFixture
	 * @Inputs this shared object
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int SummarySharedDefaultZero()
	{
		return SharedValue;
	}

	/**
	 * Observe that Idle and Active are distinct.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummarySharedFixture
	 * @Inputs ESummaryState Idle and Active
	 * @Return true when they are not equal
	 * @Boundary enum distinctness
	 */
	UFUNCTION()
	bool SummaryStateIdleActiveBoundary()
	{
		return ESummaryState::Idle != ESummaryState::Active;
	}
}
/** @end */
