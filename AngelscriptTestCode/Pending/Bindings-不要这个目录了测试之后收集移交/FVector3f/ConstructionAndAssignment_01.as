/**
 * @version v1
 * @summary Observe FVector3f assignment, value-returning arithmetic, and scalar compound multiply/divide.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f assignment, value-returning arithmetic, and scalar compound multiply/divide.
 * @topic Baseline
 */
// Vector / Other; Vector * Scale; Vector / Scale; -Vector; Vector *= Scale;
// Vector /= Scale.
// Inputs: (2,4,6), Right (1,1,1), Scale 2, Divisor 2.
// Expected observations: Assignment copies independently. + is (3,5,7).
// Component * is (2,8,18) with (1,2,3). * 2 doubles. / 2 halves. Negation
// flips signs. *= and /= mutate.
// Boundary/ownership: Value-returning operators do not mutate Source.
// Components are float32.

namespace TS_FVector3f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FVector3f Left(2.0f, 4.0f, 6.0f);
		FVector3f Right(1.0f, 1.0f, 1.0f);
		Left = Right;
		Left.X = 9.0f;
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		FVector3f Sum = Vector + Right;
		FVector3f Difference = Vector - Right;
		FVector3f ComponentProduct = Vector * FVector3f(1.0f, 2.0f, 3.0f);
		FVector3f ComponentQuotient = Vector / FVector3f(2.0f, 2.0f, 3.0f);
		FVector3f Scaled = Vector * 2.0f;
		FVector3f Quotient = Vector / 2.0f;
		FVector3f Negated = -Vector;
		return Left.X == 9.0f &&
			Right.X == 1.0f &&
			Sum.Z == 7.0f &&
			Difference.X == 1.0f &&
			ComponentProduct.Y == 8.0f &&
			ComponentQuotient.Z == 2.0f &&
			Scaled.X == 4.0f &&
			Quotient.Y == 2.0f &&
			Negated.Z == -6.0f &&
			Vector.X == 2.0f;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		Vector *= 2.0f;
		return Vector.X == 4.0f && Vector.Z == 12.0f;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		Vector /= 2.0f;
		return Vector.X == 1.0f && Vector.Y == 2.0f && Vector.Z == 3.0f;
	}
}
/** @end */
