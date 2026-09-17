/**
 * @version v1
 * @summary Observe exact FBox equality and Min/Max subscript aliasing.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe exact FBox equality and Min/Max subscript aliasing.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: bool bEqual = Left == Right; FVector& Corner = Box[Index];
// Inputs: Identical (0,0,0)-(1,1,1) boxes, a different max, index 0/1, and
// an invalid index as the diagnostic path.
// Expected observations: Identical boxes compare true. Box[0] aliases Min and
// writing through it is visible on Box.Min. Box[1] is Max.
// Boundary/ownership: Index 0 is Min, 1 is Max. Native bounds behavior applies
// for other indices.

namespace TS_FBox_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Right(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Different(FVector(0, 0, 0), FVector(2, 2, 2));
		return Left == Right && !(Left == Different);
	}

	bool Observe_Index_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(1, 1, 1));
		FVector MinCorner = Box[0];
		FVector MaxCorner = Box[1];
		Box[0] = FVector(-1, -1, -1);
		return MinCorner.X == 0.0 && MaxCorner.X == 1.0 && Box.Min.X == -1.0;
	}

	void ExerciseExpectedFailure()
	{
		FBox Box(FVector(0, 0, 0), FVector(1, 1, 1));
		FVector Invalid = Box[2];
	}
}
/** @end */
