/**
 * @version v1
 * @summary Float indices convert to int toward zero. This is permitted implicit conversion, not a CompileReject. String indices stay in Reject.
 * @topic Containers
 */
/**
 * @version root
 * @summary Float indices convert to int toward zero. This is permitted implicit conversion, not a CompileReject. String indices stay in Reject.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe float index: 0.5f -> 0, 0.0f -> 0, 1.9f -> 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> [1] then [7] then [1,2]; index with 0.5f, 0.0f, 1.9f
	 * @Return true when those reads are 1, 7, and 2
	 */
	UFUNCTION()
	bool FloatIndexTruncatesTowardZero()
	{
		TArray<int> Half;
		Half.Add(1);
		if (Half[0.5f] != 1)
		{
			return false;
		}

		TArray<int> Zero;
		Zero.Add(7);
		if (Zero[0.0f] != 7)
		{
			return false;
		}

		TArray<int> Trunc;
		Trunc.Add(1);
		Trunc.Add(2);
		return Trunc[1.9f] == 2;
	}
}
/** @end */
