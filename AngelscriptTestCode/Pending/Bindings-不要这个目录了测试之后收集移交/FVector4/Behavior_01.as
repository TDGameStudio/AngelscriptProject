/**
 * @version v1
 * @summary Observe FVector4 constructors and XYZW fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector4 constructors and XYZW fields.
 * @topic Baseline
 */
// Vector(FVector, InW); Vector(FVector4f); X; Y; Z; W.
// Inputs: (1,2,3,4), default zero, copy, FVector(5,6,7) with W 8,
// FVector4f(9,10,11,12).
// Expected observations: Default is (0,0,0,0). Copy preserves W 4. FVector
// conversion fills XYZ and the supplied W. FVector4f conversion keeps all
// four components. Fields match constructors.
// Boundary/ownership: Constructors copy values. Components are float64.

namespace TS_FVector4_Behavior_01
{
	// FVector4(X,Y,Z,W), default, copy, FVector+W, and FVector4f constructors.
	bool Observe_Vector_Nominal()
	{
		FVector4 Explicit(1, 2, 3, 4);
		FVector4 Zero;
		FVector4 Copied(Explicit);
		FVector4 From3(FVector(5, 6, 7), 8);
		FVector4 FromFloat(FVector4f(9.0f, 10.0f, 11.0f, 12.0f));
		return Explicit.W == 4.0 &&
			Zero.X == 0.0 &&
			Zero.W == 0.0 &&
			Copied.Y == 2.0 &&
			From3.X == 5.0 &&
			From3.Z == 7.0 &&
			From3.W == 8.0 &&
			FromFloat.X == 9.0 &&
			FromFloat.W == 12.0;
	}

	// FVector4.X of (1,2,3,4) is 1. Field read does not mutate.
	bool Observe_Surface006_Nominal()
	{
		return FVector4(1, 2, 3, 4).X == 1.0;
	}

	// FVector4.Y of (1,2,3,4) is 2. Field read does not mutate.
	bool Observe_Surface007_Nominal()
	{
		return FVector4(1, 2, 3, 4).Y == 2.0;
	}

	// FVector4.Z of (1,2,3,4) is 3. Field read does not mutate.
	bool Observe_Surface008_Nominal()
	{
		return FVector4(1, 2, 3, 4).Z == 3.0;
	}

	// FVector4.W of (1,2,3,4) is 4. Field read does not mutate.
	bool Observe_Surface009_Nominal()
	{
		return FVector4(1, 2, 3, 4).W == 4.0;
	}
}
/** @end */
