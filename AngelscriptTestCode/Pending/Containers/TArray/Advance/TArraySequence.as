/**
 * @version v1
 * @summary PureOutput: a recipe with no business input, assert the generated array.
 * @topic Containers
 */
/**
 * @version root
 * @summary PureOutput: a recipe with no business input, assert the generated array.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Add 0..N-1 produces a contiguous sequence.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Empty TArray<int>; Add 0, 1, 2, 3, 4
	 * @Return true when the array is [0, 1, 2, 3, 4]
	 */
	UFUNCTION()
	bool SequenceFromZeroToN()
	{
		TArray<int> Values;
		for (int Index = 0; Index < 5; ++Index)
		{
			Values.Add(Index);
		}
		return Values.Num() == 5
			&& Values[0] == 0 && Values[1] == 1 && Values[2] == 2
			&& Values[3] == 3 && Values[4] == 4;
	}

	/**
	 * In-only: C++ passes [0, 1, 2, 3, 4] and reads the sequence back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [0, 1, 2, 3, 4]
	 * @Return true when Num() == 5 and elements are 0..4
	 */
	UFUNCTION()
	bool ReadSequenceFromZeroToN(const TArray<int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 0 && Values[1] == 1 && Values[2] == 2
			&& Values[3] == 3 && Values[4] == 4;
	}

	/**
	 * Out-only: C++ receives [0, 1, 2, 3, 4] on an empty &out.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [0, 1, 2, 3, 4]
	 */
	UFUNCTION()
	void FillSequenceFromZeroToN(TArray<int>&out Result)
	{
		for (int Index = 0; Index < 5; ++Index)
		{
			Result.Add(Index);
		}
	}

	/**
	 * Inout: C++ passes [0, 1, 2]; AS appends 3 and 4.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<int>&inout, starts as [0, 1, 2]
	 * @Inputs Values.Num() == 3 with [0, 1, 2]
	 * @Return void; Values becomes [0, 1, 2, 3, 4]
	 */
	UFUNCTION()
	void AppendSequenceTail(TArray<int>&inout Values)
	{
		Values.Add(3);
		Values.Add(4);
	}

	/**
	 * Return [0, 1, 2, 3, 4] for C++ to compare.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray [0, 1, 2, 3, 4]
	 */
	UFUNCTION()
	TArray<int> ReturnSequenceFromZeroToN()
	{
		TArray<int> Result;
		for (int Index = 0; Index < 5; ++Index)
		{
			Result.Add(Index);
		}
		return Result;
	}
}
/** @end */
