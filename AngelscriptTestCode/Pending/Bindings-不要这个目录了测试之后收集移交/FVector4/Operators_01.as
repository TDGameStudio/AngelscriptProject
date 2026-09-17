/**
 * @version v1
 * @summary Observe FVector4 subscript aliasing and equality, including invalid index.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector4 subscript aliasing and equality, including invalid index.
 * @topic Baseline
 */
// bool bEqual = Left == Right.
// Inputs: (2,4,6,8), index 0 and 3, written Y 9, identical copy, different W,
// invalid index 4.
// Expected observations: [0] is X, [3] is W. Writing [1] mutates Y through
// the native non-const reference. Copies compare true.
// Boundary/ownership: Index 0..3 selects XYZW. Out-of-range is the
// diagnostic path.

namespace TS_FVector4_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FVector4 Vector(2, 4, 6, 8);
		float64 X = Vector[0];
		float64 W = Vector[3];
		Vector[1] = 9.0;
		return X == 2.0 && W == 8.0 && Vector.Y == 9.0;
	}

	bool Observe_Equality_Nominal()
	{
		FVector4 Left(2, 4, 6, 8);
		FVector4 Right(2, 4, 6, 8);
		FVector4 Different(2, 4, 6, 9);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FVector4 Vector(2, 4, 6, 8);
		float64 Invalid = Vector[4];
	}
}
/** @end */
