// Purpose: Observe FVector3f component-wise compound arithmetic and formatter
// interpolation.
// AS-facing API: Vector *= Other; Vector /= Other; Vector += Other;
// Vector -= Other; FString Text = f"{Vector}".
// Inputs: (2,4,6), Other (0.5,0.5,0.5) then (1,1,1) and (2,2,3), assigned
// (1,2,3) and zero for formatting.
// Expected observations: Component *= 0.5 halves. Component /= yields
// (1,2,2) from (2,4,6)/(2,2,3). += and -= mutate. f"{Vector}" is non-empty
// for both nonzero and zero.
// Boundary/ownership: Compound operators mutate Vector. Formatter copies
// digits into a new FString.

namespace TS_FVector3f_ConstructionAndAssignment_02
{
	bool Observe_MultiplyAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		Vector *= FVector3f(0.5f, 0.5f, 0.5f);
		return Vector.X == 1.0f && Vector.Z == 3.0f;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		Vector /= FVector3f(2.0f, 2.0f, 3.0f);
		return Vector.X == 1.0f && Vector.Y == 2.0f && Vector.Z == 2.0f;
	}

	bool Observe_AddAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		FVector3f Other(1.0f, 1.0f, 1.0f);
		Vector += Other;
		return Vector.X == 3.0f && Vector.Z == 7.0f && Other.X == 1.0f;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		Vector -= FVector3f(1.0f, 1.0f, 1.0f);
		return Vector.X == 1.0f && Vector.Z == 5.0f;
	}

	bool Observe_Assignment_Nominal()
	{
		FVector3f Vector(1.0f, 2.0f, 3.0f);
		FString Text = f"{Vector}";
		FString ZeroText = f"{FVector3f::ZeroVector}";
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.Z == 3.0f;
	}
}
