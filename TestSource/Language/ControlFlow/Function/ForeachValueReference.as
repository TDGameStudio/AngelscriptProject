/**
 * range-for walks a container without an index. The loop variable can be a
 * value, a reference, or a const reference: a value copies each element so
 * writing through it leaves the container untouched, a reference writes
 * through into the container, and a const reference reads without copying.
 * The same syntax walks a TSet, and a TMap is walked through an explicit
 * iterator that yields a key and a value per step.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachValueReference
 * @Harness Function
 * @Tag Language.ControlFlow.ForeachValueReference
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::ForEach
 * @Provenance Oracle: ForEachValue == 15; ForEachReference == 12; ForEachConstRef == 60;
 * @Provenance ForEachSet == 30; MapIteratorKeyValue == 66.
 */

namespace ControlFlowTest
{
	/**
	 * Observe the value form: each element is copied into the loop variable.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (int Val : Arr) over 1 through 5
	 * @Return 15 when every element is visited
	 */
	UFUNCTION()
	int ForeachByValueSumsElements()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		Arr.Add(4);
		Arr.Add(5);
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe the reference form: writing through the loop variable mutates
	 * the container itself.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (int& Val : Arr) over 1, 2, 3, doubling each
	 * @Return 12 when the container was doubled to 2, 4, 6
	 */
	UFUNCTION()
	int ForeachByReferenceMutatesElements()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		for (int& Val : Arr)
		{
			Val *= 2;
		}
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe the const reference form: it reads each element without copying
	 * and does not allow mutation.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (const int& Val : Arr) over 10, 20, 30
	 * @Return 60 when every element is read
	 */
	UFUNCTION()
	int ForeachByConstReferenceSumsElements()
	{
		TArray<int> Arr;
		Arr.Add(10);
		Arr.Add(20);
		Arr.Add(30);
		int Sum = 0;
		for (const int& Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe that the same syntax walks a TSet.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (int Val : Set) over 5, 10, 15
	 * @Return 30 when every member is visited
	 */
	UFUNCTION()
	int ForeachWalksSet()
	{
		TSet<int> Set;
		Set.Add(5);
		Set.Add(10);
		Set.Add(15);
		int Sum = 0;
		for (int Val : Set)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe that a TMap is walked with an explicit iterator yielding a key
	 * and a value per step.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs A TMap holding 1:10, 2:20, 3:30 walked with TMapIterator
	 * @Return 66 when every key and value pair is visited
	 */
	UFUNCTION()
	int MapIteratorYieldsKeyAndValue()
	{
		TMap<int, int> Map;
		Map.Add(1, 10);
		Map.Add(2, 20);
		Map.Add(3, 30);
		int Sum = 0;
		TMapIterator<int, int> It = Map.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
			Sum += It.GetKey() + It.GetValue();
		}
		return Sum;
	}

	/**
	 * Observe the empty default across all three container kinds: no iteration
	 * runs and each sum stays zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs An empty TArray, an empty TSet, and an empty TMap
	 * @Return true when all three produce a sum of zero
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool ForeachOverEmptyVisitsNothing()
	{
		TArray<int> EmptyArr;
		int ArrSum = 0;
		for (int Val : EmptyArr)
		{
			ArrSum += Val;
		}

		TSet<int> EmptySet;
		int SetSum = 0;
		for (int Val : EmptySet)
		{
			SetSum += Val;
		}

		TMap<int, int> EmptyMap;
		int MapSum = 0;
		TMapIterator<int, int> It = EmptyMap.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
			MapSum += It.GetKey() + It.GetValue();
		}

		if (ArrSum != 0)
		{
			return false;
		}
		if (SetSum != 0)
		{
			return false;
		}
		return MapSum == 0;
	}

	/**
	 * Observe copy independence: writing to the value-form loop variable does
	 * not write into the container.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (int Val : Arr) assigning zero to the loop variable each pass
	 * @Return true when the container still holds 1, 2, 3
	 */
	UFUNCTION()
	bool ForeachValueDoesNotAliasContainer()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		for (int Val : Arr)
		{
			Val = 0;
		}
		if (Arr[0] != 1)
		{
			return false;
		}
		if (Arr[1] != 2)
		{
			return false;
		}
		return Arr[2] == 3;
	}
}
