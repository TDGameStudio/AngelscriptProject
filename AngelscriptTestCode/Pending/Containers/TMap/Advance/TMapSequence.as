/**
 * @version v1
 * @summary PureOutput: a recipe with no business input, assert the generated map. Keys 0..4 map to the same ints. Membership, not iteration order.
 * @topic Containers
 */
/**
 * @version root
 * @summary PureOutput: a recipe with no business input, assert the generated map. Keys 0..4 map to the same ints. Membership, not iteration order.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Add 0..N-1 produces a contiguous key/value sequence.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Empty TMap<int, int>; Add 0..4 with matching values
	 * @Return true when Num is 5 and each key maps to itself
	 */
	UFUNCTION()
	bool SequenceFromZeroToN()
	{
		TMap<int, int> Values;
		for (int Index = 0; Index < 5; ++Index)
		{
			Values.Add(Index, Index);
		}
		return Values.Num() == 5
			&& Values.Contains(0) && Values[0] == 0
			&& Values.Contains(4) && Values[4] == 4
			&& !Values.Contains(5);
	}

	/**
	 * In-only: C++ passes keys 0..4 and reads the sequence back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values has keys 0..4 mapping to themselves
	 * @Return true when Num() == 5 and [i] == i for 0..4
	 */
	UFUNCTION()
	bool ReadSequenceFromZeroToN(const TMap<int, int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 0 && Values[1] == 1 && Values[2] == 2
			&& Values[3] == 3 && Values[4] == 4;
	}

	/**
	 * Out-only: fill an empty &out map with keys 0..4.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result has keys 0..4
	 */
	UFUNCTION()
	void FillSequenceFromZeroToN(TMap<int, int>&out Result)
	{
		for (int Index = 0; Index < 5; ++Index)
		{
			Result.Add(Index, Index);
		}
	}

	/**
	 * Inout: extend [0,1,2] to [0..4].
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, int>&inout, starts with 0..2
	 * @Inputs Values.Num() == 3 with keys 0, 1, 2
	 * @Return void; Values has keys 0..4
	 */
	UFUNCTION()
	void AppendSequenceFromZeroToN(TMap<int, int>&inout Values)
	{
		Values.Add(3, 3);
		Values.Add(4, 4);
	}

	/**
	 * Return keys 0..4 for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Inputs none
	 * @Return TMap with keys 0..4 mapping to themselves
	 */
	UFUNCTION()
	TMap<int, int> ReturnSequenceFromZeroToN()
	{
		TMap<int, int> Values;
		for (int Index = 0; Index < 5; ++Index)
		{
			Values.Add(Index, Index);
		}
		return Values;
	}
}
/** @end */
