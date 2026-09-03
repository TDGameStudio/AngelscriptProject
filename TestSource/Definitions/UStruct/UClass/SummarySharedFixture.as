/**
 * Preprocessor summary shared fixture: one enum, one delegate, one class, one
 * function, and two properties. C++ counts those summary rows. Keep
 * GetAmount, SharedValue, and ESummaryState.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SummarySharedFixture
 * @Harness UClass
 * @Tag Definitions.UStruct.SummarySharedFixture
 * @Provenance Theme: Definitions.UStruct. Positive preprocessor summary shared fixture.
 * @Provenance C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryReportsProcessedScriptStructure block 1
 * @Provenance Summary: 2 files, 2 modules, 1 import, 2 classes, 1 function, 2 properties, 1 enum, 1 delegate.
 * @Provenance Oracle: GetAmount()==3.0. Extra: SharedValue default 0; Idle vs Active distinct.
 * @Provenance DefaultSafe.
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
