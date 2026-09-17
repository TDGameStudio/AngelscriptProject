/**
 * @version v1
 * @summary PureOutput: a recipe with no business input, assert the generated set. Members 0..4. Membership, not iteration order.
 * @topic Containers
 */
/**
 * @version root
 * @summary PureOutput: a recipe with no business input, assert the generated set. Members 0..4. Membership, not iteration order.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Add 0..N-1 produces a contiguous membership sequence.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Empty TSet<int>; Add 0..4
	 * @Return true when Num is 5, 0 and 4 are present, and 5 is not
	 */
	UFUNCTION()
	bool SequenceFromZeroToN()
	{
		TSet<int> Values;
		for (int Index = 0; Index < 5; ++Index)
		{
			Values.Add(Index);
		}
		return Values.Num() == 5
			&& Values.Contains(0) && Values.Contains(4)
			&& !Values.Contains(5);
	}

	/**
	 * In-only: C++ passes members 0..4 and reads the sequence back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values has members 0..4
	 * @Return true when Num() == 5 and Contains(i) for 0..4
	 */
	UFUNCTION()
	bool ReadSequenceFromZeroToN(const TSet<int>&in Values)
	{
		return Values.Num() == 5
			&& Values.Contains(0) && Values.Contains(1) && Values.Contains(2)
			&& Values.Contains(3) && Values.Contains(4);
	}

	/**
	 * Out-only: fill an empty &out set with members 0..4.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result has members 0..4
	 */
	UFUNCTION()
	void FillSequenceFromZeroToN(TSet<int>&out Result)
	{
		for (int Index = 0; Index < 5; ++Index)
		{
			Result.Add(Index);
		}
	}

	/**
	 * Inout: extend [0,1,2] to [0..4].
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<int>&inout, starts with 0..2
	 * @Inputs Values.Num() == 3 with 0, 1, 2
	 * @Return void; Values has members 0..4
	 */
	UFUNCTION()
	void AppendSequenceFromZeroToN(TSet<int>&inout Values)
	{
		Values.Add(3);
		Values.Add(4);
	}

	/**
	 * Return members 0..4 for C++ set equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Inputs none
	 * @Return TSet with members 0..4
	 */
	UFUNCTION()
	TSet<int> ReturnSequenceFromZeroToN()
	{
		TSet<int> Values;
		for (int Index = 0; Index < 5; ++Index)
		{
			Values.Add(Index);
		}
		return Values;
	}
}
/** @end */
