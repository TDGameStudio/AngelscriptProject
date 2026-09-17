/**
 * @version v1
 * @summary Observe FIntVector4 const subscript and equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector4 const subscript and equality.
 * @topic Baseline
 */
// bool bEqual = Left == Right;
// Inputs: (2,4,6,8), index 0 and 3, identical copy, different W, invalid 4.
// Expected observations: [0] is X, [3] is W. Copies compare true.
// Boundary/ownership: Out-of-range index is the diagnostic path.

namespace TS_FIntVector4_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		return Vector[0] == 2 && Vector[3] == 8;
	}

	bool Observe_Equality_Nominal()
	{
		FIntVector4 Left(2, 4, 6, 8);
		FIntVector4 Right(2, 4, 6, 8);
		FIntVector4 Different(2, 4, 6, 9);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		int32 Invalid = Vector[4];
	}
}
/** @end */
