// Purpose: Observe FSphere3f enclosing-combination operators.
// AS-facing API: FSphere3f Combined = Left + Right; Sphere += Other;
// Inputs: Left origin radius 1, Right at (10,0,0) radius 1, a copied original,
// and a nested smaller sphere.
// Expected observations: Combined radius is greater than either operand.
// += mutates the left sphere to enclose Other. Nested += does not shrink.
// Original copy stays radius 1.
// Boundary/ownership: + returns a new enclosing sphere. += mutates the left
// operand only. Radius is Sphere.W.

namespace TS_FSphere3f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FSphere3f Left(FVector3f::ZeroVector, 1.0);
		FSphere3f Right(FVector3f(10.0, 0.0, 0.0), 1.0);
		FSphere3f Original = Left;
		FSphere3f Combined = Left + Right;
		return Combined.W > Left.W && Combined.W > Right.W && Original.W == 1.0 && Left.W == 1.0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FSphere3f Sphere(FVector3f::ZeroVector, 1.0);
		FSphere3f Other(FVector3f(10.0, 0.0, 0.0), 1.0);
		Sphere += Other;
		FSphere3f Nested(FVector3f::ZeroVector, 0.5);
		FSphere3f Host(FVector3f::ZeroVector, 2.0);
		float32 HostRadius = Host.W;
		Host += Nested;
		return Sphere.W > 1.0 && Host.W >= HostRadius && Other.W == 1.0;
	}
}
