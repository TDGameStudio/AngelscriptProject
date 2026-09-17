/**
 * @version v1
 * @summary Observe FIntVector2 const subscript and equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector2 const subscript and equality.
 * @topic Baseline
 */
// bool bEqual = Left == Right;
// Inputs: (2,4), index 0/1, identical copy, different Y, invalid index 2.
// Expected observations: [0] is X. Copies compare true.
// Boundary/ownership: Subscript returns a const alias. Out-of-range is
// diagnostic.

namespace TS_FIntVector2_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FIntVector2 Vector(2, 4);
		return Vector[0] == 2 && Vector[1] == 4;
	}

	bool Observe_Equality_Nominal()
	{
		FIntVector2 Left(2, 4);
		FIntVector2 Right(2, 4);
		FIntVector2 Different(2, 5);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FIntVector2 Vector(2, 4);
		int32 Invalid = Vector[2];
	}
}
/** @end */
