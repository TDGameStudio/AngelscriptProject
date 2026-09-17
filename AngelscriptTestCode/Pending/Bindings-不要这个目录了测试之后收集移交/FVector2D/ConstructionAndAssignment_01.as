/**
 * @version v1
 * @summary Observe FVector2D type declaration, assignment, and in-place arithmetic, including formatter append.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2D type declaration, assignment, and in-place arithmetic, including formatter append.
 * @topic Baseline
 */
// Vector /= Scale; Vector *= Other; Vector /= Other; Vector += Other;
// Vector -= Other; Text += Vector;
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2, component scale (0.5,0.5),
// text "v:".
// Expected observations: Assignment copies independently. *= 2 doubles.
// /= 2 halves. Component *= and /= scale each axis. += and -= mutate.
// Text += grows length.
// Boundary/ownership: Compound operators mutate Vector. Text append copies
// formatted digits.

namespace TS_FVector2D_ConstructionAndAssignment_01
{
	// struct FVector2D; default Value is (0,0). Declaration, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FVector2D Value;
		return Value.X == 0.0 && Value.Y == 0.0;
	}

	// Vector = Other copies XY; mutating Vector.X does not alias Other.
	bool Observe_Assignment_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Other(1, 1);
		Vector = Other;
		Vector.X = 9.0;
		return Vector.X == 9.0 && Other.X == 1.0 && Other.Y == 1.0;
	}

	// Vector *= Scale then *= Other: (2,4)*2 is (4,8); *0.5 restores (2,4). Mutates receiver.
	bool Observe_MultiplyAssign_Nominal()
	{
		FVector2D Vector(2, 4);
		Vector *= 2.0;
		bool bScale = Vector.X == 4.0 && Vector.Y == 8.0;
		Vector *= FVector2D(0.5, 0.5);
		return bScale && Vector.X == 2.0 && Vector.Y == 4.0;
	}

	// Vector /= Scale then /= Other: (2,4)/2 is (1,2); /(1,2) is (1,1). Mutates receiver.
	bool Observe_DivideAssign_Nominal()
	{
		FVector2D Vector(2, 4);
		Vector /= 2.0;
		bool bScale = Vector.X == 1.0 && Vector.Y == 2.0;
		Vector /= FVector2D(1, 2);
		return bScale && Vector.X == 1.0 && Vector.Y == 1.0;
	}

	// Vector += Other: (2,4)+(1,1) is (3,5). Other is unchanged.
	bool Observe_AddAssign_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Other(1, 1);
		Vector += Other;
		return Vector.X == 3.0 && Vector.Y == 5.0 && Other.X == 1.0;
	}

	// Vector -= Other then Text += Vector: (2,4)-(1,1) is (1,3); append grows length.
	bool Observe_SubtractAssign_Nominal()
	{
		FVector2D Vector(2, 4);
		Vector -= FVector2D(1, 1);
		FString Text = "v:";
		Text += Vector;
		return Vector.X == 1.0 && Vector.Y == 3.0 && Text.Len() > 2;
	}
}
/** @end */
