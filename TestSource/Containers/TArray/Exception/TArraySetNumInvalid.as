/**
 * SetNum and SetNumZeroed throw on a negative size. SetNumZeroed also throws
 * when T is not a primitive (for example FString).
 *
 * @Theme Containers.TArray
 * @Subject TArray.SetNum
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArraySetNumInvalid
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * SetNum with a negative size throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.SetNum
	 * @Inputs Empty TArray<int>; SetNum(-1)
	 * @Return void; throws "Invalid negative Num"
	 * @Boundary NewNum < 0
	 */
	UFUNCTION()
	void SetNumNegative()
	{
		TArray<int> Values;
		Values.SetNum(-1);
	}

	/**
	 * SetNumZeroed with a negative size throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.SetNumZeroed
	 * @Inputs Empty TArray<int>; SetNumZeroed(-1)
	 * @Return void; throws "Invalid negative Num"
	 * @Boundary NewNum < 0
	 */
	UFUNCTION()
	void SetNumZeroedNegative()
	{
		TArray<int> Values;
		Values.SetNumZeroed(-1);
	}

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
