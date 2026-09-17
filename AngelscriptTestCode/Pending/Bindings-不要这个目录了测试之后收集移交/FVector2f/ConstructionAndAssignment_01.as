/**
 * @version v1
 * @summary Observe FVector2f assignment and value-returning arithmetic, including scalar bias and negation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f assignment and value-returning arithmetic, including scalar bias and negation.
 * @topic Baseline
 */
// Vector - Bias; Vector * Other; Vector * Scale; Vector / Other; Vector / Scale;
// -Vector.
// Inputs: (2,4), Other (1,1), Bias 1, Scale 2, Divisor 2.
// Expected observations: Assignment copies independently. + is (3,5). Bias
// + is (3,5). Component * is (2,8). * 2 is (4,8). / 2 is (1,2). Negation
// flips signs. Original Vector is unchanged by value-returning operators.
// Boundary/ownership: Components are float32. Compound mutation is not used
// here. Assignment does not alias Other.

namespace TS_FVector2f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		FVector2f Other(1.0f, 1.0f);
		Vector = Other;
		Vector.X = 9.0f;
		FVector2f Source(2.0f, 4.0f);
		FVector2f Sum = Source + Other;
		FVector2f BiasedSum = Source + 1.0f;
		FVector2f Difference = Source - Other;
		FVector2f BiasedDifference = Source - 1.0f;
		FVector2f ComponentProduct = Source * FVector2f(1.0f, 2.0f);
		FVector2f Scaled = Source * 2.0f;
		FVector2f ComponentQuotient = Source / FVector2f(2.0f, 2.0f);
		FVector2f Quotient = Source / 2.0f;
		FVector2f Negated = -Source;
		return Vector.X == 9.0f &&
			Other.X == 1.0f &&
			Sum.X == 3.0f &&
			BiasedSum.Y == 5.0f &&
			Difference.X == 1.0f &&
			BiasedDifference.Y == 3.0f &&
			ComponentProduct.Y == 8.0f &&
			Scaled.X == 4.0f &&
			ComponentQuotient.X == 1.0f &&
			Quotient.Y == 2.0f &&
			Negated.X == -2.0f &&
			Source.X == 2.0f;
	}
}
/** @end */
