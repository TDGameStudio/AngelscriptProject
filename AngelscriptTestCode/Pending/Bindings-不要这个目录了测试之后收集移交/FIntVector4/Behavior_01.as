/**
 * @version v1
 * @summary Observe FIntVector4 constructors and X/Y/Z/W fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector4 constructors and X/Y/Z/W fields.
 * @topic Baseline
 */
namespace TS_FIntVector4_Behavior_01
{
	// FIntVector4(X,Y,Z,W), default zero, uniform F, and copy. Inputs (1,2,3,4) and 7.
	bool Observe_Vector_Nominal()
	{
		FIntVector4 Explicit(1, 2, 3, 4);
		FIntVector4 Zero;
		FIntVector4 Uniform(7);
		FIntVector4 Copied(Explicit);
		return Explicit.W == 4 && Zero.X == 0 && Uniform.Z == 7 && Copied.Y == 2;
	}

	// FIntVector4.X of (1,2,3,4) is 1. Query, no fixture.
	bool Observe_Surface005_Nominal()
	{
		return FIntVector4(1, 2, 3, 4).X == 1;
	}

	// FIntVector4.Y of (1,2,3,4) is 2. Query, no fixture.
	bool Observe_Surface006_Nominal()
	{
		return FIntVector4(1, 2, 3, 4).Y == 2;
	}

	// FIntVector4.Z of (1,2,3,4) is 3. Query, no fixture.
	bool Observe_Surface007_Nominal()
	{
		return FIntVector4(1, 2, 3, 4).Z == 3;
	}

	// FIntVector4.W of (1,2,3,4) is 4. Query, no fixture.
	bool Observe_Surface008_Nominal()
	{
		return FIntVector4(1, 2, 3, 4).W == 4;
	}
}
/** @end */
