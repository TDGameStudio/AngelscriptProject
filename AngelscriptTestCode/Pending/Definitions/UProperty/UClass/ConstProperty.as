/**
 * @version v1
 * @summary A const UPROPERTY currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover ConstVal 5 and that a local snapshot mutation does not change the property.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A const UPROPERTY currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover ConstVal 5 and that a local snapshot mutation does not change the property.
 * @topic Baseline
 */
class AUPropConstPropActor : AActor
{
	UPROPERTY()
	const int ConstVal = 5;

	/**
	 * Observe the default ConstVal of 5.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs none
	 * @Return true when ConstVal is 5
	 */
	UFUNCTION()
	bool ConstValDefault()
	{
		return ConstVal == 5;
	}

	/**
	 * Observe that ConstVal is not the empty 0 boundary.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs none
	 * @Return true when ConstVal is not 0
	 * @Boundary non-zero initializer
	 */
	UFUNCTION()
	bool ConstValNotZeroBoundary()
	{
		return ConstVal != 0;
	}

	/**
	 * Observe that mutating a local copy leaves ConstVal at 5.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs a local copy written to 0
	 * @Return 5 from ConstVal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int ConstValCopySnapshot()
	{
		int Copy = ConstVal;
		Copy = 0;
		return ConstVal;
	}
}
/** @end */
