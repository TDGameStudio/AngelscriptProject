/**
 * @version v1
 * @summary A valueless default statement currently compiles: C++ wraps the AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent). X stays at its inline 0. Keep X.
 * @topic Feature
 */
/**
 * @version root
 * @summary A valueless default statement currently compiles: C++ wraps the AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent). X stays at its inline 0. Keep X.
 * @topic Baseline
 */
class AAttrNoValActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrNoValActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that X stays at the inline zero.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 */
	UFUNCTION()
	int XStaysZero()
	{
		return X;
	}

	/**
	 * Observe that a write of 1 lands and can be restored.
	 *
	 * @Kind Observe
	 * @Covers Default.WithoutValue
	 * @Inputs X written to 1 then restored
	 * @Return 1, the value after the write
	 * @Boundary write then restore
	 */
	UFUNCTION()
	int WriteBoundary()
	{
		int Saved = X;
		X = 1;
		int After = X;
		X = Saved;
		return After;
	}
}
/** @end */
