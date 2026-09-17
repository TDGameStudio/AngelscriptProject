/**
 * @version v1
 * @summary Observe IsValidIndex, FindIndex, explicit iterators, Proceed aliasing, and copy-constructed iterator state. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe IsValidIndex, FindIndex, explicit iterators, Proceed aliasing, and copy-constructed iterator state. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// int32 Index = Array.FindIndex(const T&in Value) const;
// TArrayIterator<T> Iterator(const TArrayIterator<T>& Other);
// T& Value = Iterator.Proceed();
// TArrayConstIterator<T> ConstIterator(const TArrayConstIterator<T>& Other);
// const T& Value = ConstIterator.Proceed();
// TArrayIterator<T> Iterator = Array.Iterator();
// TArrayConstIterator<T> Iterator = Array.Iterator() const;
// Inputs: Empty array, populated {10, 20, 30}, first index 0, last index 2,
// missing value 99, and Proceed past the end as the diagnostic.
// Expected observations: Empty has no valid index. FindIndex(20) is 1 and
// missing is -1. Iterator visits 10 then 20. Mutable Proceed alias write is
// visible on Array[0]. Const iterator reads the same values.
// Boundary/ownership: Iterators alias array storage. Proceed past the last
// element raises a script exception.

namespace TS_TArray_IndexAndIteration_01
{
	bool Observe_IsValidIndex_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(30);
		return !Empty.IsValidIndex(0) && !Empty.IsValidIndex(-1) && Array.IsValidIndex(0) && Array.IsValidIndex(2) && !Array.IsValidIndex(3);
	}

	bool Observe_FindIndex_Nominal()
	{
		TArray<int32> Empty;
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		Array.Add(10);
		return Empty.FindIndex(10) == -1 && Array.FindIndex(10) == 0 && Array.FindIndex(20) == 1 && Array.FindIndex(99) == -1;
	}

	bool Observe_Iterator_Nominal()
	{
		TArray<int32> Empty;
		TArrayIterator<int32> EmptyIt = Empty.Iterator();
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		TArrayIterator<int32> Other = Array.Iterator();
		TArrayIterator<int32> Iterator(Other);
		const TArray<int32> ConstArray = Array;
		TArrayConstIterator<int32> ConstOther = ConstArray.Iterator();
		TArrayConstIterator<int32> ConstIterator(ConstOther);
		return !EmptyIt.CanProceed && Iterator.CanProceed && Other.CanProceed && ConstIterator.CanProceed;
	}

	bool Observe_Proceed_Nominal()
	{
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		TArrayIterator<int32> Iterator = Array.Iterator();
		int32& First = Iterator.Proceed();
		bool bFirstIsTen = First == 10;
		First = 11;
		bool bCanContinue = Iterator.CanProceed;
		int32& Second = Iterator.Proceed();
		return bFirstIsTen && Array[0] == 11 && bCanContinue && Second == 20 && !Iterator.CanProceed;
	}

	bool Observe_ConstIterator_Nominal()
	{
		TArray<int32> Array;
		Array.Add(10);
		Array.Add(20);
		const TArray<int32> ConstArray = Array;
		TArrayConstIterator<int32> ConstIterator = ConstArray.Iterator();
		const int32& First = ConstIterator.Proceed();
		const int32& Second = ConstIterator.Proceed();
		return First == 10 && Second == 20 && !ConstIterator.CanProceed;
	}

	void ExerciseExpectedFailure()
	{
		TArray<int32> Array;
		Array.Add(10);
		TArrayIterator<int32> Iterator = Array.Iterator();
		Iterator.Proceed();
		int32& PastEnd = Iterator.Proceed();
	}
}
/** @end */
