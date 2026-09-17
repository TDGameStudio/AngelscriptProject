/**
 * @version v1
 * @summary Observe FIntVector4 assignment and compound arithmetic.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector4 assignment and compound arithmetic.
 * @topic Baseline
 */
// *=; /=; +=; -=.
// Inputs: (2,4,6,8), Other (1,1,1,1), Scale 2, Divisor 2.
// Expected observations: Assignment copies W. * 2 doubles W to 16. Integer
// / 2 halves. += mutates in place.
// Boundary/ownership: Compound operators mutate Left. Integer division
// truncates.

namespace TS_FIntVector4_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FIntVector4 Left(2, 4, 6, 8);
		FIntVector4 Right(1, 1, 1, 1);
		Left = Right;
		FIntVector4 Sum = Left + Right;
		FIntVector4 Difference = Left - Right;
		FIntVector4 Negated = -Left;
		return Left.W == 1 && Sum.X == 2 && Difference.X == 0 && Negated.X == -1;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		FIntVector4 Scaled = Vector * 2;
		Vector *= 2;
		return Scaled.W == 16 && Vector.W == 16;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		FIntVector4 Quotient = Vector / 2;
		Vector /= 2;
		return Quotient.W == 4 && Vector.W == 4;
	}

	bool Observe_AddAssign_Nominal()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		Vector += FIntVector4(1, 1, 1, 1);
		return Vector.W == 9;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FIntVector4 Vector(2, 4, 6, 8);
		Vector -= FIntVector4(1, 1, 1, 1);
		return Vector.W == 7;
	}
}
/** @end */
