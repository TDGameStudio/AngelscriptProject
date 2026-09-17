/**
 * @version v1
 * @summary Observe FVector type declaration, assignment, and in-place arithmetic, including formatter append.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector type declaration, assignment, and in-place arithmetic, including formatter append.
 * @topic Baseline
 */
// Vector /= Scale; Vector *= Other; Vector /= Other; Vector += Other;
// Vector -= Other; Text += Vector;
// Inputs: (2,4,6), Other (1,1,1), Scale 2, Divisor 2, component scale
// (0.5,0.5,0.5), text "v:".
// Expected observations: Assignment copies components independently.
// *= 2 doubles. /= 2 halves. Component *= and /= scale each axis. += and -=
// mutate in place. Text += grows length.
// Boundary/ownership: Compound operators mutate Vector. Value copies do not
// alias Other. Text append copies formatted digits.

namespace TS_FVector_ConstructionAndAssignment_01
{
	// struct FVector; default Value is (0,0,0). Declaration, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FVector Value;
		return Value.X == 0.0 && Value.Y == 0.0 && Value.Z == 0.0;
	}

	// Vector = Other copies XYZ; mutating Vector.X does not alias Other.
	bool Observe_Assignment_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Other(1, 1, 1);
		Vector = Other;
		Vector.X = 9.0;
		return Vector.X == 9.0 && Other.X == 1.0 && Other.Z == 1.0;
	}

	// Vector *= Scale then *= Other: (2,4,6)*2 is (4,8,12); *0.5 restores (2,4,6). Mutates receiver.
	bool Observe_MultiplyAssign_Nominal()
	{
		FVector Vector(2, 4, 6);
		Vector *= 2.0;
		bool bScale = Vector.X == 4.0 && Vector.Y == 8.0 && Vector.Z == 12.0;
		Vector *= FVector(0.5, 0.5, 0.5);
		return bScale && Vector.X == 2.0 && Vector.Z == 6.0;
	}

	// Vector /= Scale then /= Other: (2,4,6)/2 is (1,2,3); /(1,2,3) is (1,1,1). Mutates receiver.
	bool Observe_DivideAssign_Nominal()
	{
		FVector Vector(2, 4, 6);
		Vector /= 2.0;
		bool bScale = Vector.X == 1.0 && Vector.Y == 2.0 && Vector.Z == 3.0;
		Vector /= FVector(1, 2, 3);
		return bScale && Vector.X == 1.0 && Vector.Y == 1.0 && Vector.Z == 1.0;
	}

	// Vector += Other: (2,4,6)+(1,1,1) is (3,5,7). Other is unchanged.
	bool Observe_AddAssign_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Other(1, 1, 1);
		Vector += Other;
		return Vector.X == 3.0 && Vector.Z == 7.0 && Other.X == 1.0;
	}

	// Vector -= Other then Text += Vector: (2,4,6)-(1,1,1) is (1,3,5); append grows length.
	bool Observe_SubtractAssign_Nominal()
	{
		FVector Vector(2, 4, 6);
		Vector -= FVector(1, 1, 1);
		FString Text = "v:";
		Text += Vector;
		return Vector.X == 1.0 && Vector.Z == 5.0 && Text.Len() > 2;
	}
}
/** @end */
