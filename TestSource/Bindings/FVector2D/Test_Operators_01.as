// Purpose: Observe FVector2D value-returning arithmetic, scalar bias, and
// subscript, including invalid index.
// AS-facing API: Vector + Other; Vector - Other; Vector * Other; Vector / Other;
// Vector * Scale; Vector / Scale; Vector + Bias; Vector - Bias; Vector[Index];
// ConstVector[Index].
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2, Bias 1, index 0/1, invalid
// index 2.
// Expected observations: + is (3,5). Component * is (2,8). * 2 is (4,8).
// + Bias is (3,5). [0] is X. Index write mutates Y. Const index reads X.
// Boundary/ownership: Value-returning operators do not mutate Vector.
// Index 0/1 are X/Y. Out-of-range is the diagnostic path.

namespace TS_FVector2D_Operators_01
{
	// Vector + Other and Vector + Bias: (2,4)+(1,1) and +1 are (3,5). Source X stays 2.
	bool Observe_Addition_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Sum = Vector + FVector2D(1, 1);
		FVector2D Biased = Vector + 1.0;
		return Sum.X == 3.0 && Sum.Y == 5.0 && Biased.X == 3.0 && Biased.Y == 5.0 && Vector.X == 2.0;
	}

	// Vector - Other and Vector - Bias: (2,4)-(1,1) and -1 are (1,3).
	bool Observe_Subtraction_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Difference = Vector - FVector2D(1, 1);
		FVector2D Biased = Vector - 1.0;
		return Difference.X == 1.0 && Difference.Y == 3.0 && Biased.X == 1.0 && Biased.Y == 3.0;
	}

	// Vector * Other is per-component: (2,4)*(1,2) is (2,8). Source Y stays 4.
	bool Observe_Surface011_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Product = Vector * FVector2D(1, 2);
		return Product.X == 2.0 && Product.Y == 8.0 && Vector.Y == 4.0;
	}

	// Vector / Other is per-component: (2,4)/(2,2) is (1,2).
	bool Observe_Surface012_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Quotient = Vector / FVector2D(2, 2);
		return Quotient.X == 1.0 && Quotient.Y == 2.0;
	}

	// Vector * Scale: (2,4)*2 is (4,8). Source X stays 2.
	bool Observe_Surface013_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Scaled = Vector * 2.0;
		return Scaled.X == 4.0 && Scaled.Y == 8.0 && Vector.X == 2.0;
	}

	// Vector / Scale: (2,4)/2 is (1,2).
	bool Observe_Surface014_Nominal()
	{
		FVector2D Vector(2, 4);
		FVector2D Quotient = Vector / 2.0;
		return Quotient.X == 1.0 && Quotient.Y == 2.0;
	}

	// Vector[Index]: [0] is X, [1] is Y, write [1] mutates Y. Const index reads X. Range 0..1.
	bool Observe_Index_Nominal()
	{
		FVector2D Vector(2, 4);
		const FVector2D ConstVector(2, 4);
		float64 X = Vector[0];
		float64 Y = Vector[1];
		Vector[1] = 9.0;
		float64 ConstX = ConstVector[0];
		return X == 2.0 && Y == 4.0 && Vector.Y == 9.0 && ConstX == 2.0 && ConstVector.Y == 4.0;
	}

	void ExerciseExpectedFailure()
	{
		FVector2D Vector(2, 4);
		float64 Invalid = Vector[2];
	}
}
