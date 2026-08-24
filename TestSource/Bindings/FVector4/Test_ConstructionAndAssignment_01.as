// Purpose: Observe FVector4 assignment, value-returning arithmetic, in-place
// scale, and formatter interpolation.
// AS-facing API: Left = Right; Sum = Left + Right; Difference = Left - Right;
// Scaled = Vector * Scale; Quotient = Vector / Divisor; Vector *= Scale;
// FString Text = f"{Vector}".
// Inputs: (2,4,6,8), Right (1,1,1,1), Scale 2, Divisor 2, formatted (1,2,3,4)
// and zero.
// Expected observations: Assignment copies W independently. + is (3,5,7,9).
// * 2 doubles W to 16. / 2 halves. *= mutates. f"{Vector}" is non-empty.
// Boundary/ownership: Value-returning operators do not mutate. Formatter
// copies digits into a new FString. Components are float64.

namespace TS_FVector4_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FVector4 Left(2, 4, 6, 8);
		FVector4 Right(1, 1, 1, 1);
		Left = Right;
		Left.W = 9.0;
		FVector4 Vector(2, 4, 6, 8);
		FVector4 Sum = Vector + Right;
		FVector4 Difference = Vector - Right;
		FVector4 Scaled = Vector * 2.0;
		FVector4 Quotient = Vector / 2.0;
		FVector4 Zero;
		FString Text = f"{Vector}";
		FString ZeroText = f"{Zero}";
		return Left.W == 9.0 &&
			Right.W == 1.0 &&
			Sum.X == 3.0 &&
			Sum.W == 9.0 &&
			Difference.X == 1.0 &&
			Scaled.W == 16.0 &&
			Quotient.W == 4.0 &&
			Text.Len() > 0 &&
			ZeroText.Len() > 0 &&
			Vector.W == 8.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FVector4 Vector(2, 4, 6, 8);
		Vector *= 2.0;
		return Vector.X == 4.0 && Vector.W == 16.0;
	}
}
