// Purpose: Observe mutable and const TArray subscript aliasing plus element
// equality of whole arrays. Each function returns the exact comparison.
// AS-facing API: T& Value = Array[Index]; const T& Value = Array[Index];
// bool bEqual = Left == Right;
// Inputs: Array {1, 2}, identical Right, empty RightEmpty, index 0 and last
// index 1, and out-of-range index 8 as the diagnostic.
// Expected observations: Array[0] is 1. Writing through the mutable
// reference is visible on a later read. Const subscript reads without
// mutation. Equal arrays compare true; empty vs populated is false.
// Boundary/ownership: Subscript returns an alias into array storage. An
// invalid index raises a script exception.

namespace TS_TArray_Operators_01
{
	bool Observe_Index_Nominal()
	{
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		int32& Mutable = Array[0];
		bool bFirstIsOne = Mutable == 1;
		Mutable = 9;
		int32 AfterWrite = Array[0];
		int32 Last = Array[1];
		const TArray<int32> ConstArray = Array;
		const int32& ConstFirst = ConstArray[0];
		TArray<FName> Names;
		Names.Add(n"Alpha");
		FName& NameAlias = Names[0];
		return bFirstIsOne && AfterWrite == 9 && Last == 2 && ConstFirst == 9 && NameAlias == n"Alpha";
	}

	bool Observe_Equality_Nominal()
	{
		TArray<int32> Left;
		Left.Add(1);
		Left.Add(2);
		TArray<int32> Right;
		Right.Add(1);
		Right.Add(2);
		TArray<int32> EmptyLeft;
		TArray<int32> EmptyRight;
		TArray<int32> Different;
		Different.Add(1);
		return Left == Right && EmptyLeft == EmptyRight && !(Left == EmptyLeft) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		TArray<int32> Array;
		Array.Add(1);
		int32 OutOfRange = Array[8];
	}
}
