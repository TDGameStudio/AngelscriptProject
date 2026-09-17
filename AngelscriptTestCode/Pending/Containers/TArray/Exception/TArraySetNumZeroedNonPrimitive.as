/**
 * @version v1
 * @summary SetNumZeroed throws when T is not a primitive (for example FString).
 * @topic Containers
 */
/**
 * @version root
 * @summary SetNumZeroed throws when T is not a primitive (for example FString).
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * SetNumZeroed is not valid for FString.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.SetNumZeroed
	 * @Inputs Empty TArray<FString>; SetNumZeroed(2)
	 * @Return void; throws "SetNumZeroed is not valid for arrays of non-primitive types."
	 * @Boundary T is not primitive
	 */
	UFUNCTION()
	void SetNumZeroedOnFString()
	{
		TArray<FString> Values;
		Values.SetNumZeroed(2);
	}
}
/** @end */
