/**
 * @version v1
 * @summary Observe FVector value-returning arithmetic, subscript, equality, and string concatenation, including invalid index.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector value-returning arithmetic, subscript, equality, and string concatenation, including invalid index.
 * @topic Baseline
 */
// Vector * Scale; Vector / Scale; Vector[Index]; ConstVector[Index];
// Vector == Other; Text + Vector;
// Inputs: (2,4,6), Other (1,1,1), Scale 2, Divisor 2, index 0/2, prefix "v:",
// invalid index 3.
// Expected observations: + is (3,5,7). Component * is (2,8,18). * 2 doubles.
// [0] is X and [2] is Z. Copies compare true. Text + Vector is longer than
// the prefix. Index write mutates Y.
// Boundary/ownership: Value-returning operators do not mutate Vector.
// Index 0..2 selects XYZ. Out-of-range is the diagnostic path.

namespace TS_FVector_Operators_01
{
	// Vector + Other and FString + Vector: (2,4,6)+(1,1,1) is (3,*,7); concat grows; source stays 2.
	bool Observe_Addition_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Sum = Vector + FVector(1, 1, 1);
		FString Combined = FString("v:") + Vector;
		return Sum.X == 3.0 && Sum.Z == 7.0 && Combined.Len() > 2 && Vector.X == 2.0;
	}

	// Vector - Other: (2,4,6)-(1,1,1) is (1,*,5). Source is unchanged.
	bool Observe_Subtraction_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Difference = Vector - FVector(1, 1, 1);
		return Difference.X == 1.0 && Difference.Z == 5.0 && Vector.X == 2.0;
	}

	// Vector * Other is per-component: (2,4,6)*(1,2,3) is (2,8,18). Source Y stays 4.
	bool Observe_Surface014_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Product = Vector * FVector(1, 2, 3);
		return Product.X == 2.0 && Product.Y == 8.0 && Product.Z == 18.0 && Vector.Y == 4.0;
	}

	// Vector / Other is per-component: (2,4,6)/(2,2,3) is (1,2,2).
	bool Observe_Surface015_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Quotient = Vector / FVector(2, 2, 3);
		return Quotient.X == 1.0 && Quotient.Y == 2.0 && Quotient.Z == 2.0;
	}

	// Vector * Scale: (2,4,6)*2 is (4,*,12). Source X stays 2.
	bool Observe_Surface016_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Scaled = Vector * 2.0;
		return Scaled.X == 4.0 && Scaled.Z == 12.0 && Vector.X == 2.0;
	}

	// Vector / Scale: (2,4,6)/2 is (1,2,3).
	bool Observe_Surface017_Nominal()
	{
		FVector Vector(2, 4, 6);
		FVector Quotient = Vector / 2.0;
		return Quotient.X == 1.0 && Quotient.Y == 2.0 && Quotient.Z == 3.0;
	}

	// Vector[Index]: [0] is X, [2] is Z, write [1] mutates Y. Const index reads Z. Range 0..2.
	bool Observe_Index_Nominal()
	{
		FVector Vector(2, 4, 6);
		const FVector ConstVector(2, 4, 6);
		float64 X = Vector[0];
		float64 Z = Vector[2];
		Vector[1] = 9.0;
		float64 ConstZ = ConstVector[2];
		return X == 2.0 && Z == 6.0 && Vector.Y == 9.0 && ConstZ == 6.0 && ConstVector.Y == 4.0;
	}

	// Vector == Other is exact: copies compare true; Z differs false.
	bool Observe_Equality_Nominal()
	{
		FVector Left(2, 4, 6);
		FVector Right(2, 4, 6);
		FVector Different(2, 4, 7);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FVector Vector(2, 4, 6);
		float64 Invalid = Vector[3];
	}
}
/** @end */
