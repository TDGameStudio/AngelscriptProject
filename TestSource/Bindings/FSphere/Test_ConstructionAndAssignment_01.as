// Purpose: Observe FSphere enclosing-combination operators.
// AS-facing API: FSphere Combined = Left + Right; Left += Right;
// Inputs: Left origin radius 1, Right at (10,0,0) radius 1, a copied original,
// and a nested smaller sphere.
// Expected observations: Combined radius is greater than either operand.
// += mutates Left to enclose Right. Nested += does not shrink. Original copy
// stays radius 1.
// Boundary/ownership: + returns a new enclosing sphere. += mutates Left only.

namespace TS_FSphere_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FSphere Left(FVector::ZeroVector, 1.0);
		FSphere Right(FVector(10.0, 0.0, 0.0), 1.0);
		FSphere Original = Left;
		FSphere Combined = Left + Right;
		return Combined.W > Left.W && Combined.W > Right.W && Original.W == 1.0 && Left.W == 1.0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FSphere Left(FVector::ZeroVector, 1.0);
		FSphere Right(FVector(10.0, 0.0, 0.0), 1.0);
		Left += Right;
		FSphere Nested(FVector::ZeroVector, 0.5);
		FSphere Host(FVector::ZeroVector, 2.0);
		float64 HostRadius = Host.W;
		Host += Nested;
		return Left.W > 1.0 && Host.W >= HostRadius && Right.W == 1.0;
	}
}
