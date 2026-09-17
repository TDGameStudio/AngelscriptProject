/**
 * @version v1
 * @summary Observe FIntPoint type declaration, constructors, X/Y fields, and Size.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntPoint type declaration, constructors, X/Y fields, and Size.
 * @topic Baseline
 */
// X; Y; Size().
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7, copy of (3,4).
// Expected observations: Default is (0,0). Uniform 7 is (7,7). Copy preserves
// (3,4). Size of (3,4) is 5.
// Boundary/ownership: Size is integer length of the vector. Construction
// copies values.

namespace TS_FIntPoint_Behavior_01
{
	// FIntPoint Value; default construction is (0, 0). No fixture.
	bool Observe_Surface001_Nominal()
	{
		FIntPoint Value;
		return Value.X == 0 && Value.Y == 0;
	}

	// FIntPoint(X,Y), FIntPoint(), FIntPoint(F), and copy. Inputs (3,4), 7, copy of (3,4).
	bool Observe_Value_Nominal()
	{
		FIntPoint Explicit(3, 4);
		FIntPoint Zero;
		FIntPoint Uniform(7);
		FIntPoint Copied(Explicit);
		return Explicit.X == 3 && Uniform.X == 7 && Uniform.Y == 7 && Copied.Y == 4;
	}

	// FIntPoint.X field of (3,4) is 3. Query, no fixture.
	bool Observe_Surface006_Nominal()
	{
		FIntPoint Point(3, 4);
		return Point.X == 3;
	}

	// FIntPoint.Y field of (3,4) is 4. Query, no fixture.
	bool Observe_Surface007_Nominal()
	{
		FIntPoint Point(3, 4);
		return Point.Y == 4;
	}

	// FIntPoint.Size of (3,4) is 5 and Size of (0,0) is 0. Integer Euclidean length.
	bool Observe_Size_Nominal()
	{
		FIntPoint Point(3, 4);
		FIntPoint Zero(0, 0);
		return Point.Size() == 5 && Zero.Size() == 0;
	}
}
/** @end */
