/**
 * @version v1
 * @summary Observe Contains, Num, Max, GetAllocatedSize, IsEmpty, and GetSlack on empty and populated arrays, including after Reserve. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Contains, Num, Max, GetAllocatedSize, IsEmpty, and GetSlack on empty and populated arrays, including after Reserve. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// int Count = Array.Num() const; int Capacity = Array.Max() const;
// int64 Bytes = Array.GetAllocatedSize() const;
// bool bEmpty = Array.IsEmpty() const; int Slack = Array.GetSlack() const;
// Inputs: Default-empty array, {1, 2, 1} as the populated state, lookup 2 and
// missing 9, and Reserve(8) as the capacity boundary.
// Expected observations: Empty Num is 0, IsEmpty true, Contains false.
// Populated Num is 3, Contains 2 true and 9 false. After Reserve(8), Max is
// at least 8 and GetSlack is Max-Num. GetAllocatedSize is >= 0.
// Boundary/ownership: Queries do not mutate. Slack is unused allocated
// capacity, not Num. DefaultSafe.

namespace TS_TArray_Queries_01
{
	bool Observe_Contains_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(1);
		TArray<FString> Texts;
		Texts.Add("Alpha");
		return !Empty.Contains(1) && Array.Contains(2) && !Array.Contains(9) && Texts.Contains("Alpha");
	}

	bool Observe_Num_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		return Empty.Num() == 0 && Array.Num() == 2;
	}

	bool Observe_Max_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		Array.Reserve(8);
		int ReservedMax = Array.Max();
		return Empty.Max() >= 0 && ReservedMax >= 8 && ReservedMax >= Array.Num();
	}

	bool Observe_GetAllocatedSize_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		Array.Reserve(8);
		int64 EmptyBytes = Empty.GetAllocatedSize();
		int64 PopulatedBytes = Array.GetAllocatedSize();
		return EmptyBytes >= 0 && PopulatedBytes >= EmptyBytes;
	}

	bool Observe_IsEmpty_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		return Empty.IsEmpty() && !Array.IsEmpty();
	}

	bool Observe_GetSlack_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(1);
		Array.Reserve(8);
		int Slack = Array.GetSlack();
		return Empty.GetSlack() >= 0 && Slack == Array.Max() - Array.Num() && Slack >= 0;
	}
}
/** @end */
