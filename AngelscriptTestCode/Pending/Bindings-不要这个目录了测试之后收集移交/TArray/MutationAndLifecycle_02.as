/**
 * @version v1
 * @summary Observe order-preserving and swap removals, Sort, and Shrink.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe order-preserving and swap removals, Sort, and Shrink.
 * @topic Baseline
 */
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: int Removed = Array.RemoveSingle(const T&in Value);
// int Removed = Array.Remove(const T&in Value);
// int Removed = Array.RemoveSingleSwap(const T&in Value);
// int Removed = Array.RemoveSwap(const T&in Value);
// Array.RemoveAt(int32 Index); Array.RemoveAtSwap(int32 Index);
// Array.Sort(bool bDescendingOrder = false); Array.Shrink();
// Inputs: Seeded {1, 2, 1, 3}, missing value 9, RemoveAt index 1, Sort
// ascending then descending, Reserve-then-empty for Shrink, and RemoveAt(-1)
// as the diagnostic.
// Expected observations: RemoveSingle removes one match. Remove removes all
// matches. Swap variants also return removed counts. RemoveAt drops Num by 1.
// Sort orders 1,2,3 then 3,2,1. Shrink after Empty does not revive elements.
// Boundary/ownership: Swap removals may reorder survivors. RemoveAt out of
// range throws. Shrink releases slack; it does not change Num of a populated
// array beyond compacting capacity.

namespace TS_TArray_MutationAndLifecycle_02
{
	bool Observe_RemoveSingle_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(1);
		int Removed = Array.RemoveSingle(1);
		int Missing = Array.RemoveSingle(9);
		return Removed == 1 && Missing == 0 && Array.Num() == 2 && Array.Contains(1);
	}

	bool Observe_Remove_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(1);
		int Removed = Array.Remove(1);
		int Missing = Array.Remove(9);
		return Removed == 2 && Missing == 0 && Array.Num() == 1 && Array[0] == 2;
	}

	bool Observe_RemoveSingleSwap_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(1);
		int Removed = Array.RemoveSingleSwap(1);
		int Missing = Array.RemoveSingleSwap(9);
		return Removed == 1 && Missing == 0 && Array.Num() == 2;
	}

	bool Observe_RemoveSwap_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(1);
		int Removed = Array.RemoveSwap(1);
		int Missing = Array.RemoveSwap(9);
		return Removed == 2 && Missing == 0 && Array.Num() == 1 && Array.Contains(2);
	}

	bool Observe_RemoveAt_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.RemoveAt(1);
		return Array.Num() == 2 && Array[0] == 1 && Array[1] == 3;
	}

	bool Observe_RemoveAtSwap_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.RemoveAtSwap(0);
		return Array.Num() == 2 && !Array.Contains(1);
	}

	bool Observe_Sort_Nominal()
	{
		TArray<int32> Array;
		Array.Add(3);
		Array.Add(1);
		Array.Add(2);
		Array.Sort();
		bool bAscending = Array.Num() == 3 && Array[0] == 1 && Array[1] == 2 && Array[2] == 3;
		Array.Sort(true);
		bool bDescending = Array[0] == 3 && Array[1] == 2 && Array[2] == 1;
		Array.Sort(false);
		return bAscending && bDescending && Array[0] == 1 && Array[2] == 3;
	}

	bool Observe_Shrink_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Reserve(16);
		int SlackBefore = Array.GetSlack();
		Array.Shrink();
		int SlackAfter = Array.GetSlack();
		bool bPopulatedShrink = Array.Num() == 1 && Array[0] == 1 && SlackAfter <= SlackBefore;
		Array.Empty(16);
		Array.Shrink();
		return bPopulatedShrink && Array.IsEmpty();
	}

	void ExerciseExpectedFailure()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.RemoveAt(-1);
	}
}
/** @end */
