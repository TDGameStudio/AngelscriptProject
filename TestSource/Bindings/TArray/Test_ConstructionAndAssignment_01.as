// Purpose: Observe TArray copy assignment, MoveAssignFrom emptying the source,
// and iterator assignment for mutable and const iterators. Each function
// returns the exact comparison for the C++ runner.
// AS-facing API: Left = Right;
// Array.MoveAssignFrom(TArray<T>& OtherArray);
// Iterator = Other; ConstIterator = Other;
// Inputs: Right = {1, 2}, an independent Left copy, a move source {10, 20},
// and iterators taken before and after assignment.
// Expected observations: Copy assignment yields equal contents and later
// mutation of Right does not change Left. MoveAssignFrom leaves the source
// empty and transfers Num. Copied iterators CanProceed together on a
// populated array.
// Boundary/ownership: Copy duplicates elements. MoveAssignFrom consumes
// OtherArray storage. Iterators alias the array, not a snapshot of values.

namespace TS_TArray_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		TArray<int32> Right;
		Right.Add(1);
		Right.Add(2);
		TArray<int32> Left;
		Left = Right;
		bool bCopiedEqual = Left == Right && Left.Num() == 2 && Left[0] == 1;
		Right.Add(3);
		bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
		TArray<FString> StringRight;
		StringRight.Add("Alpha");
		TArray<FString> StringLeft;
		StringLeft = StringRight;
		TArrayIterator<int32> Iterator;
		TArrayIterator<int32> Other = Left.Iterator();
		Iterator = Other;
		const TArray<int32> ConstLeft = Left;
		TArrayConstIterator<int32> ConstIterator;
		TArrayConstIterator<int32> ConstOther = ConstLeft.Iterator();
		ConstIterator = ConstOther;
		return bCopiedEqual && bCopyIndependent && StringLeft.Num() == 1 && StringLeft[0] == "Alpha" && Iterator.CanProceed && Other.CanProceed && ConstIterator.CanProceed && ConstOther.CanProceed;
	}

	bool Observe_MoveAssignFrom_Nominal()
	{
		TArray<int32> Source;
		Source.Add(10);
		Source.Add(20);
		TArray<int32> Destination;
		Destination.Add(1);
		Destination.MoveAssignFrom(Source);
		return Destination.Num() == 2 && Destination[0] == 10 && Destination[1] == 20 && Source.IsEmpty() && Source.Num() == 0;
	}
}
