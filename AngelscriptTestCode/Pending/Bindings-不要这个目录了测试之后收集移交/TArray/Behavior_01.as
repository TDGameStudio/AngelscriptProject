/**
 * @version v1
 * @summary Observe empty construction, Swap, Last from the end, Copy ranges, range-for protocols, and mutable iterator CanProceed. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe empty construction, Swap, Last from the end, Copy ranges, range-for protocols, and mutable iterator CanProceed. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// const T& Value = Array.Last(int32 IndexFromEnd = 0) const;
// T& Value = Array.Last(int32 IndexFromEnd = 0);
// Array.Copy(const TArray<T>& SourceArray, int32 SourceIndex, int32 Count, int TargetIndex = 0);
// for (T& Value : Array); for (const T& Value : Array);
// for (int Index, T& Value : Array); for (int Index, const T& Value : Array);
// bool Iterator.CanProceed;
// Inputs: Empty constructor, {10, 20, 30, 40} for Swap/Last/Copy/for, Last(1)
// as the from-end boundary, Copy of two elements onto a sized dest, and
// Swap(-1, 0) as the diagnostic.
// Expected observations: Default Array is empty. Swap exchanges 10 and 30.
// Last() is 40 and Last(1) is 30; mutable Last write-through is visible.
// Copy places source[1..2] at dest index 0. Range-for visits every element
// and index. Empty iterator CanProceed is false.
// Boundary/ownership: Last and Swap throw on an invalid index. Copy cannot
// target the same array. Range-for aliases live elements.

namespace TS_TArray_Behavior_01
{
	// Default TArray construction is empty for int32 and FName.
	bool Observe_Array_Nominal()
	{
		TArray<int32> Array = TArray<int32>();
		TArray<FName> Names = TArray<FName>();
		return Array.IsEmpty() && Array.Num() == 0 && Names.IsEmpty();
	}

	// Swap(0, 2) exchanges 10 and 30; Swap(1, 1) leaves 20.
	bool Observe_Swap_Nominal()
	{
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(30);
		Array.Swap(0, 2);
		Array.Swap(1, 1);
		return Array[0] == 30 && Array[2] == 10 && Array[1] == 20 && Array.Num() == 3;
	}

	// Last() aliases 30 then writes 31; Last(1) is 20; const Last matches.
	bool Observe_Last_Nominal()
	{
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(30);
		int32& LastMut = Array.Last();
		bool bLastIsThirty = LastMut == 30;
		LastMut = 31;
		int32& FromEnd = Array.Last(1);
		const TArray<int32> ConstArray = Array;
		const int32& ConstLast = ConstArray.Last();
		const int32& ConstFromEnd = ConstArray.Last(1);
		return bLastIsThirty && Array[2] == 31 && FromEnd == 20 && ConstLast == 31 && ConstFromEnd == 20;
	}

	// Copy places source[1..2] at dest[0]; explicit target index 1 stores 10,20.
	bool Observe_Copy_Nominal()
	{
		TArray<int32> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		Source.Add(40);
		TArray<int32> Dest;
		Dest.SetNum(3);
		Dest.Copy(Source, 1, 2);
		TArray<int32> DestIndexed;
		DestIndexed.SetNum(4);
		DestIndexed.Copy(Source, 0, 2, 1);
		return Dest.Num() >= 2 && Dest[0] == 20 && Dest[1] == 30 && DestIndexed[1] == 10 && DestIndexed[2] == 20;
	}

	// Range-for sums 10+20+30; indexed form adds 0+1+2.
	bool Observe_for_Nominal()
	{
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(30);
		int32 MutableSum = 0;
		for (int32& Value : Array)
		{
			MutableSum += Value;
		}
		int32 ConstSum = 0;
		const TArray<int32> ConstArray = Array;
		for (const int32& Value : ConstArray)
		{
			ConstSum += Value;
		}
		int32 IndexedMutable = 0;
		for (int Index, int32& Value : Array)
		{
			IndexedMutable += Value + Index;
		}
		int32 IndexedConst = 0;
		for (int Index, const int32& Value : ConstArray)
		{
			IndexedConst += Value + Index;
		}
		return MutableSum == 60 && ConstSum == 60 && IndexedMutable == 63 && IndexedConst == 63;
	}

	// Empty iterator CanProceed is false; populated starts true then exhausts.
	bool Observe_Surface043_Nominal()
	{
		TArray<int32> Empty;
		TArrayIterator<int32> EmptyIt = Empty.Iterator();
		TArray<int32> Array;
		Array.Add(1);
		TArrayIterator<int32> Iterator = Array.Iterator();
		bool bPopulatedCanProceed = Iterator.CanProceed;
		Iterator.Proceed();
		return !EmptyIt.CanProceed && bPopulatedCanProceed && !Iterator.CanProceed;
	}

	void ExerciseExpectedFailure()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Swap(-1, 0);
	}
}
/** @end */
