/**
 * @version v1
 * @summary TArray.Iterator() is the explicit form of the foreach walk. The returned TArrayIterator<T> exposes CanProceed as a property and Proceed() to advance and yield the current element, so the walk can be driven by hand rather.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray.Iterator() is the explicit form of the foreach walk. The returned TArrayIterator<T> exposes CanProceed as a property and Proceed() to advance and yield the current element, so the walk can be driven by hand rather.
 * @topic Baseline
 */
UCLASS()
class UTArrayIteratorObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Iterator: driving CanProceed and Proceed walks every element in order.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs TArray<int> [1,2,3,4,5]; walk with CanProceed / Proceed
	 * @Return true when five elements are yielded in order
	 */
	UFUNCTION()
	bool IteratorWalksEveryElementInOrder()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);
		Array.Add(5);

		TArrayIterator<int> It = Array.Iterator();

		int Count = 0;
		int Sum = 0;
		while (It.CanProceed)
		{
			Sum += It.Proceed();
			Count = Count + 1;
		}

		if (Count != 5)
		{
			return false;
		}
		return Sum == 15;
	}

	/**
	 * Observe the const overload: a const& array yields a const iterator that
	 * walks the same elements.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs A const TArray<int> [10,20,30] reached through a const local
	 * @Return true when the const iterator yields three elements
	 * @Boundary const TArray<T>::Iterator() const overload
	 */
	UFUNCTION()
	bool ConstIteratorWalksConstArray()
	{
		TArray<int> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(30);

		const TArray<int>& ConstArray = Array;
		TArrayConstIterator<int> It = ConstArray.Iterator();

		int Count = 0;
		int Sum = 0;
		while (It.CanProceed)
		{
			Sum += It.Proceed();
			Count = Count + 1;
		}

		if (Count != 3)
		{
			return false;
		}
		return Sum == 60;
	}

	/**
	 * Observe that Iterator on an empty array yields nothing and CanProceed
	 * starts false.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs Empty TArray<int>; Iterator()
	 * @Return true when CanProceed is false at the start
	 */
	UFUNCTION()
	bool IteratorOnEmptyYieldsNothing()
	{
		TArray<int> Array;

		TArrayIterator<int> It = Array.Iterator();
		if (It.CanProceed)
		{
			return false;
		}
		return Array.Num() == 0;
	}

	/**
	 * Observe that an iterator can be copied and assigned: the copy continues
	 * from the same position rather than restarting.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs TArray<int> [1,2,3,4]; advance the first iterator, copy it, continue with the copy
	 * @Return true when the copy continues from the advanced position
	 */
	UFUNCTION()
	bool IteratorCopyContinuesFromSamePosition()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		TArrayIterator<int> First = Array.Iterator();
		First.Proceed();

		TArrayIterator<int> Copy = First;
		int Next = Copy.Proceed();
		if (Next != 2)
		{
			return false;
		}
		return Copy.CanProceed;
	}

	/**
	 * Observe that a fresh iterator restarts from the beginning even after
	 * another iterator has walked the same array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs TArray<int> [7,8]; walk one iterator to exhaustion; take a fresh one
	 * @Return true when the fresh iterator yields 7 again
	 */
	UFUNCTION()
	bool FreshIteratorRestartsFromBeginning()
	{
		TArray<int> Array;
		Array.Add(7);
		Array.Add(8);

		TArrayIterator<int> First = Array.Iterator();
		while (First.CanProceed)
		{
			First.Proceed();
		}

		TArrayIterator<int> Second = Array.Iterator();
		if (!Second.CanProceed)
		{
			return false;
		}
		return Second.Proceed() == 7;
	}

	/**
	 * In-only: walk a const&in array with the const iterator.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds [1,2,3]
	 * @Return true when the walk yields three elements summing to 6
	 */
	UFUNCTION()
	bool WalkWithConstIterator(const TArray<int>&in Values)
	{
		TArrayConstIterator<int> It = Values.Iterator();

		int Count = 0;
		int Sum = 0;
		while (It.CanProceed)
		{
			Sum += It.Proceed();
			Count = Count + 1;
		}

		if (Count != 3)
		{
			return false;
		}
		return Sum == 6;
	}

	/**
	 * Out-only: fill an &out array and walk it with an iterator.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds [1,2,3]
	 */
	UFUNCTION()
	void FillAndWalk(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);

		TArrayIterator<int> It = Result.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
		}
	}

	/**
	 * Inout: walk an existing array with an iterator without modifying it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Values Array received as TArray<int>&inout, holds [1,2,3]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values is unchanged
	 */
	UFUNCTION()
	void WalkInPlace(TArray<int>&inout Values)
	{
		TArrayIterator<int> It = Values.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
		}
	}


	/**
	 * Observe Iterator for FString: the walk yields every string in order.
	 *
	 * @Kind Observe
	 * @Covers TArray.Iterator
	 * @Inputs TArray<FString> ["a","b","c"]; walk with CanProceed / Proceed
	 * @Return true when three strings are yielded in order
	 */
	UFUNCTION()
	bool IteratorWalksEveryElementInOrder_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("c");

		TArrayIterator<FString> It = Array.Iterator();

		int Count = 0;
		FString Joined = "";
		while (It.CanProceed)
		{
			Joined += It.Proceed();
			Count = Count + 1;
		}

		if (Count != 3)
		{
			return false;
		}
		return Joined == "abc";
	}

	/**
	 * In-only: walk a const&in TArray<FString> with the const iterator.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds ["a","b"]
	 * @Return true when the walk yields two strings
	 */
	UFUNCTION()
	bool WalkWithConstIterator_FString(const TArray<FString>&in Values)
	{
		TArrayConstIterator<FString> It = Values.Iterator();

		int Count = 0;
		FString Joined = "";
		while (It.CanProceed)
		{
			Joined += It.Proceed();
			Count = Count + 1;
		}

		if (Count != 2)
		{
			return false;
		}
		return Joined == "ab";
	}

	/**
	 * Out-only: fill an &out TArray<FString> and walk it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result holds ["a","b"]
	 */
	UFUNCTION()
	void FillAndWalk_FString(TArray<FString>&out Result)
	{
		Result.Add("a");
		Result.Add("b");

		TArrayIterator<FString> It = Result.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
		}
	}

	/**
	 * Inout: walk an existing TArray<FString> without modifying it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Iterator
	 * @Param Values Array received as TArray<FString>&inout, holds ["a","b"]
	 * @Inputs Values.Num() is 2
	 * @Return void; Values is unchanged
	 */
	UFUNCTION()
	void WalkInPlace_FString(TArray<FString>&inout Values)
	{
		TArrayIterator<FString> It = Values.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
		}
	}
}
/** @end */
