// Purpose: Observe FVector4f type declaration, assignment, in-place scale,
// and string append.
// AS-facing API: struct FVector4f; Vector = Other; Vector *= S; Text += Vector.
// Inputs: Default/zero, (2,4,6,8), Other (1,1,1,1), Scale 2, text "v:".
// Expected observations: Default is (0,0,0,0). Assignment copies W
// independently. *= 2 doubles W to 16. Text += grows length.
// Boundary/ownership: *= mutates Vector. Text append copies formatted
// digits. Components are float32.

namespace TS_FVector4f_ConstructionAndAssignment_01
{
	// Default FVector4f is (0,0,0,0). Value type, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FVector4f Value;
		return Value.X == 0.0f && Value.Y == 0.0f && Value.Z == 0.0f && Value.W == 0.0f;
	}

	// Assignment copies independently; mutating W does not alias Other.
	bool Observe_Assignment_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Other(1.0f, 1.0f, 1.0f, 1.0f);
		Vector = Other;
		Vector.W = 9.0f;
		return Vector.W == 9.0f && Other.W == 1.0f && Other.X == 1.0f;
	}

	// Vector *= 2 doubles each component, including W to 16.
	bool Observe_MultiplyAssign_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		Vector *= 2.0f;
		return Vector.X == 4.0f && Vector.W == 16.0f;
	}

	// FString += FVector4f appends formatted digits and leaves the vector unchanged.
	bool Observe_AddAssign_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FString Text = "v:";
		Text += Vector;
		return Text.Len() > 2 && Vector.W == 8.0f;
	}
}
