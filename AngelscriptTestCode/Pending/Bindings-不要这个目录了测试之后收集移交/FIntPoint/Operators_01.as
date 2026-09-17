/**
 * @version v1
 * @summary Observe FIntPoint subscript and equality, including invalid index.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntPoint subscript and equality, including invalid index.
 * @topic Baseline
 */
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
/** @end */
