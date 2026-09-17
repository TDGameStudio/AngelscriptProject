/**
 * @version v1
 * @summary Observe FIntPoint assignment and arithmetic compound operators.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntPoint assignment and arithmetic compound operators.
 * @topic Baseline
 */
// Point * Scale; Point / Divisor; *=; /=; +=; -=.
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2, zero (0,0).
// Expected observations: + is (3,5). * 2 is (4,8). / 2 is (1,2). += mutates
// in place. Zero addition is stable. Integer division truncates.
// Boundary/ownership: Value-returning operators do not mutate Point.

namespace TS_FIntPoint_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Other(1, 1);
		Point = Other;
		FIntPoint Sum = Point + Other;
		FIntPoint Difference = Point - Other;
		FIntPoint Negated = -Point;
		return Point.X == 1 && Point.Y == 1 && Sum.X == 2 && Difference.X == 0 && Negated.X == -1;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Scaled = Point * 2;
		Point *= 2;
		return Scaled.X == 4 && Point.X == 4 && Point.Y == 8;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Quotient = Point / 2;
		Point /= 2;
		return Quotient.X == 1 && Point.X == 1 && Point.Y == 2;
	}

	bool Observe_AddAssign_Nominal()
	{
		FIntPoint Point(2, 4);
		Point += FIntPoint(1, 1);
		return Point.X == 3 && Point.Y == 5;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FIntPoint Point(2, 4);
		Point -= FIntPoint(1, 1);
		return Point.X == 1 && Point.Y == 3;
	}
}
/** @end */
