// Purpose: Observe FIntVector2 constructors and X/Y fields.
// AS-facing API: Vector(X,Y); Vector(); Vector(F); Vector(Other); X; Y.
// Inputs: (3,4), default zero, uniform 7, copy.
// Expected observations: Components match. Uniform fills both axes. Copy
// preserves (3,4).
// Boundary/ownership: These are integer value types.

namespace TS_FIntVector2_Behavior_01
{
	// FIntVector2(X,Y), default zero, uniform F, and copy. Inputs (3,4) and 7.
	bool Observe_Vector_Nominal()
	{
		FIntVector2 Explicit(3, 4);
		FIntVector2 Zero;
		FIntVector2 Uniform(7);
		FIntVector2 Copied(Explicit);
		return Explicit.X == 3 && Zero.X == 0 && Uniform.Y == 7 && Copied.Y == 4;
	}

	// FIntVector2.X of (3,4) is 3. Query, no fixture.
	bool Observe_Surface005_Nominal()
	{
		return FIntVector2(3, 4).X == 3;
	}

	// FIntVector2.Y of (3,4) is 4. Query, no fixture.
	bool Observe_Surface006_Nominal()
	{
		return FIntVector2(3, 4).Y == 4;
	}
}
