/**
 * @version v1
 * @summary Observe FBox3f value-returning union, equality, point expansion, subscript, and string concatenation. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox3f value-returning union, equality, point expansion, subscript, and string concatenation. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// Text + Box;
// Inputs: Identical (0,0,0)-(1,1,1), different max, point (2,2,2), index 0/1,
// prefix "box:".
// Expected observations: + of boxes grows the copy. == is true for identical
// corners. Box[0] is Min. Text + Box is longer than the prefix.
// Boundary/ownership: + does not mutate Box. Invalid index is the diagnostic
// path.

namespace TS_FBox3f_Operators_01
{
	bool Observe_Addition_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FBox3f Other(FVector3f(1, 1, 1), FVector3f(2, 2, 2));
		FBox3f Union = Box + Other;
		FBox3f Expanded = Box + FVector3f(2, 2, 2);
		FString Combined = FString("box:") + Box;
		return Union.Max.X == 2.0 && Expanded.Max.X == 2.0 && Combined.Len() > 4 && Box.Max.X == 1.0;
	}

	bool Observe_Equality_Nominal()
	{
		FBox3f Left(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FBox3f Right(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FBox3f Different(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		return (Left == Right) && !(Left == Different);
	}

	bool Observe_Index_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FVector3f MinCorner = Box[0];
		FVector3f MaxCorner = Box[1];
		return MinCorner.X == 0.0 && MaxCorner.X == 1.0;
	}

	void ExerciseExpectedFailure()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FVector3f Invalid = Box[2];
	}
}
/** @end */
