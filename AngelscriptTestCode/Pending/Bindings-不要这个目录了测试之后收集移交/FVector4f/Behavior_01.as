/**
 * @version v1
 * @summary Observe FVector4f constructors and XYZW fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector4f constructors and XYZW fields.
 * @topic Baseline
 */
// Vector(FVector3f, InW); Vector(FVector4); X; Y; Z; W.
// Inputs: (1,2,3,4), default zero, copy, FVector3f(5,6,7) with W 8,
// FVector4(9,10,11,12).
// Expected observations: Default is (0,0,0,0). Copy preserves W 4. FVector3f
// conversion fills XYZ and the supplied W. FVector4 conversion keeps all
// four components. Fields match constructors.
// Boundary/ownership: Constructors copy values. Components are float32.

namespace TS_FVector4f_Behavior_01
{
	// FVector4f(X,Y,Z,W), default, copy, FVector3f+W, and FVector4 constructors.
	bool Observe_Vector_Nominal()
	{
		FVector4f Explicit(1.0f, 2.0f, 3.0f, 4.0f);
		FVector4f Zero;
		FVector4f Copied(Explicit);
		FVector4f From3(FVector3f(5.0f, 6.0f, 7.0f), 8.0f);
		FVector4f FromDouble(FVector4(9, 10, 11, 12));
		return Explicit.W == 4.0f &&
			Zero.X == 0.0f &&
			Zero.W == 0.0f &&
			Copied.Y == 2.0f &&
			From3.X == 5.0f &&
			From3.Z == 7.0f &&
			From3.W == 8.0f &&
			FromDouble.X == 9.0f &&
			FromDouble.W == 12.0f;
	}

	// FVector4f.X of (1,2,3,4) is 1. Field read does not mutate.
	bool Observe_Surface007_Nominal()
	{
		return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).X == 1.0f;
	}

	// FVector4f.Y of (1,2,3,4) is 2. Field read does not mutate.
	bool Observe_Surface008_Nominal()
	{
		return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).Y == 2.0f;
	}

	// FVector4f.Z of (1,2,3,4) is 3. Field read does not mutate.
	bool Observe_Surface009_Nominal()
	{
		return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).Z == 3.0f;
	}

	// FVector4f.W of (1,2,3,4) is 4. Field read does not mutate.
	bool Observe_Surface010_Nominal()
	{
		return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).W == 4.0f;
	}
}
/** @end */
