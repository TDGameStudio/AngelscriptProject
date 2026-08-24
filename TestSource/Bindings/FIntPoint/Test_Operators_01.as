// Purpose: Observe FIntPoint subscript and equality, including invalid index.
// AS-facing API: int32 Component = Point[Index]; bool bEqual = Point == Other;
// Inputs: (2,4), index 0 and 1, identical copy, different Y, invalid index 2.
// Expected observations: [0] is X, [1] is Y. Identical copies compare true.
// Boundary/ownership: Index 0/1 are X/Y. Out-of-range is the diagnostic path.

namespace TS_FIntPoint_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FIntPoint Point(2, 4);
		return Point[0] == 2 && Point[1] == 4;
	}

	bool Observe_Equality_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Other(2, 4);
		FIntPoint Different(2, 5);
		return (Point == Other) && !(Point == Different);
	}

	void ExerciseExpectedFailure()
	{
		FIntPoint Point(2, 4);
		int32 Invalid = Point[2];
	}
}
