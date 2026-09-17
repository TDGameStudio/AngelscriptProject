/**
 * @version v1
 * @summary Observe FIntVector constructors, X/Y/Z fields, negation, and Size.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector constructors, X/Y/Z fields, negation, and Size.
 * @topic Baseline
 */
// -Vector; Size().
// Inputs: (3,4,12) so Size is 13, uniform 7, copy, zero default.
// Expected observations: Components match constructors. Uniform 7 fills all
// axes. Negation flips signs. Size of (3,4,12) is 13.
// Boundary/ownership: Size is integer length. Constructors copy values.

namespace TS_FIntVector_Behavior_01
{
	// FIntVector(X,Y,Z), default zero, uniform F, and copy. Inputs (3,4,12) and 7.
	bool Observe_Vector_Nominal()
	{
		FIntVector Explicit(3, 4, 12);
		FIntVector Zero;
		FIntVector Uniform(7);
		FIntVector Copied(Explicit);
		return Explicit.Z == 12 && Zero.IsZero() && Uniform.Y == 7 && Copied.X == 3;
	}

	// FIntVector.X of (3,4,12) is 3. Query, no fixture.
	bool Observe_Surface006_Nominal()
	{
		return FIntVector(3, 4, 12).X == 3;
	}

	// FIntVector.Y of (3,4,12) is 4. Query, no fixture.
	bool Observe_Surface007_Nominal()
	{
		return FIntVector(3, 4, 12).Y == 4;
	}

	// FIntVector.Z of (3,4,12) is 12. Query, no fixture.
	bool Observe_Surface008_Nominal()
	{
		return FIntVector(3, 4, 12).Z == 12;
	}

	// Unary -FIntVector(3,4,12) is (-3,-4,-12). Value-returning, no fixture.
	bool Observe_Surface012_Nominal()
	{
		FIntVector Negated = -FIntVector(3, 4, 12);
		return Negated.X == -3 && Negated.Z == -12;
	}

	// FIntVector.Size of (3,4,12) is 13 and Size of zero is 0. Integer Euclidean length.
	bool Observe_Size_Nominal()
	{
		return FIntVector(3, 4, 12).Size() == 13 && FIntVector(0, 0, 0).Size() == 0;
	}
}
/** @end */
