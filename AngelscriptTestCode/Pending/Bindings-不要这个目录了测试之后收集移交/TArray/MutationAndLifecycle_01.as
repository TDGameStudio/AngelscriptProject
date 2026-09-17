/**
 * @version v1
 * @summary Observe Add/Append/Shuffle/Insert/AddUnique and allocation mutations Empty/Reset/Reserve/SetNum/SetNumZeroed. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Add/Append/Shuffle/Insert/AddUnique and allocation mutations Empty/Reset/Reserve/SetNum/SetNumZeroed. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// Array.Shuffle(); Array.Insert(const T&in Value, int32 Index = 0);
// bool bAdded = Array.AddUnique(const T&in Value);
// Array.Empty(int32 ReservedSize = 0); Array.Reset(int32 ReservedSize = 0);
// Array.Reserve(int32 ReservedSize = 0); Array.SetNum(int32 NewNum = 0);
// Array.SetNumZeroed(int32 NewNum = 0);
// Inputs: Seeded {1}, Other {2, 3}, Insert 9 at 1 and at default 0, AddUnique
// duplicate 1 vs new 4, Empty/Reset with and without reserved size, Reserve(8),
// SetNum 3 then 0, SetNumZeroed 2, and Insert(-1) as the diagnostic.
// Expected observations: Add/Append grow Num. Insert shifts following
// elements. AddUnique is false for a duplicate and true for a new value.
// Empty/Reset yield Num 0. SetNumZeroed appends zeros. Shuffle preserves Num
// and membership.
// Boundary/ownership: Insert out of range throws. SetNumZeroed is valid for
// int32. Empty may keep slack when ReservedSize is set.

namespace TS_TArray_MutationAndLifecycle_01
{
	bool Observe_Add_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		TArray<FString> Texts;
		Texts.Add("Alpha");
		TArray<UObject> Objects;
		UObject NullObject = nullptr;
		Objects.Add(NullObject);
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TArray_MutationAndLifecycle_01 setup: required Actor CDO is null");
		}
		Objects.Add(LiveCdo);
		return Array.Num() == 2 && Array[0] == 1 && Array[1] == 2 && Texts.Num() == 1 && Texts[0] == "Alpha" && Objects.Num() == 2 && Objects[0] is null && Objects[1] == LiveCdo;
	}

	bool Observe_Append_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		TArray<int32> Other;
		Other.Add(2);
		Other.Add(3);
		Array.Append(Other);
		TArray<int32> EmptyOther;
		Array.Append(EmptyOther);
		return Array.Num() == 3 && Array[1] == 2 && Array[2] == 3 && Other.Num() == 2;
	}

	bool Observe_Shuffle_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Shuffle();
		return Array.Num() == 3 && Array.Contains(1) && Array.Contains(2) && Array.Contains(3);
	}

	bool Observe_Insert_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(3);
		Array.Insert(9, 1);
		bool bInsertedAtOne = Array.Num() == 3 && Array[0] == 1 && Array[1] == 9 && Array[2] == 3;
		Array.Insert(0);
		return bInsertedAtOne && Array[0] == 0 && Array.Num() == 4;
	}

	bool Observe_AddUnique_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		bool bDuplicate = Array.AddUnique(1);
		bool bUnique = Array.AddUnique(4);
		return !bDuplicate && bUnique && Array.Num() == 2 && Array.Contains(4);
	}

	bool Observe_Empty_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Empty();
		bool bDefaultEmpty = Array.IsEmpty() && Array.Num() == 0;
		Array.Add(1);
		Array.Empty(8);
		return bDefaultEmpty && Array.IsEmpty() && Array.Max() >= 8;
	}

	bool Observe_Reset_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Reset();
		bool bDefaultReset = Array.IsEmpty();
		Array.Add(1);
		Array.Reset(4);
		return bDefaultReset && Array.IsEmpty() && Array.Max() >= 4;
	}

	bool Observe_Reserve_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		int CountBefore = Array.Num();
		Array.Reserve(8);
		Array.Reserve();
		return Array.Num() == CountBefore && Array.Max() >= 8 && Array[0] == 1;
	}

	bool Observe_SetNum_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.SetNum(3);
		bool bGrew = Array.Num() == 3 && Array[0] == 1;
		Array.SetNum(1);
		bool bShrunk = Array.Num() == 1 && Array[0] == 1;
		Array.SetNum();
		return bGrew && bShrunk && Array.Num() == 0;
	}

	bool Observe_SetNumZeroed_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.SetNumZeroed(3);
		bool bGrewZeroed = Array.Num() == 3 && Array[0] == 1 && Array[1] == 0 && Array[2] == 0;
		Array.SetNumZeroed();
		return bGrewZeroed && Array.Num() == 0;
	}

	void ExerciseExpectedFailure()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Insert(9, -1);
	}
}
/** @end */
