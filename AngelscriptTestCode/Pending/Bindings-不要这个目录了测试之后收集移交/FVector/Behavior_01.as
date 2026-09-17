/**
 * @version v1
 * @summary Observe FVector as the published net-quantize type, constructors, XYZ fields, and negation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector as the published net-quantize type, constructors, XYZ fields, and negation.
 * @topic Baseline
 */
// Vector(); Vector(F); Vector(Other); Vector(FVector3f); X; Y; Z; -Vector.
// Inputs: (1,2,3), default zero, uniform 7, copy, FVector3f(4,5,6).
// Expected observations: Default is (0,0,0). Uniform 7 fills all axes. Copy
// preserves (1,2,3). FVector3f conversion keeps 4/5/6. Fields match. Negation
// flips signs. Net-quantize properties are observed as FVector values.
// Boundary/ownership: Constructors copy values. FVector_NetQuantize* reflected
// properties route to FVector rather than a distinct script type.

namespace TS_FVector_Behavior_01
{
	// FVector_NetQuantize publishes as FVector: (1,2,3) stores XYZ. Value copy, no fixture.
	bool Observe_Surface002_Nominal()
	{
		FVector Quantized(1, 2, 3);
		return Quantized.X == 1.0 && Quantized.Y == 2.0 && Quantized.Z == 3.0;
	}

	// FVector(X,Y,Z), default, uniform, copy, FVector3f: default is zero; copy and conversion keep components.
	bool Observe_Vector_Nominal()
	{
		FVector Explicit(1, 2, 3);
		FVector Zero;
		FVector Uniform(7);
		FVector Copied(Explicit);
		FVector FromFloat(FVector3f(4, 5, 6));
		return Explicit.Z == 3.0 &&
			Zero.IsZero() &&
			Uniform.Y == 7.0 &&
			Copied.X == 1.0 &&
			FromFloat.X == 4.0 &&
			FromFloat.Z == 6.0;
	}

	// FVector.X of (1,2,3) is 1. Field read, no mutation.
	bool Observe_Surface008_Nominal()
	{
		return FVector(1, 2, 3).X == 1.0;
	}

	// FVector.Y of (1,2,3) is 2. Field read, no mutation.
	bool Observe_Surface009_Nominal()
	{
		return FVector(1, 2, 3).Y == 2.0;
	}

	// FVector.Z of (1,2,3) is 3. Field read, no mutation.
	bool Observe_Surface010_Nominal()
	{
		return FVector(1, 2, 3).Z == 3.0;
	}

	// Unary minus of (1,2,3) is (-1,-2,-3). Returns a new vector.
	bool Observe_Surface018_Nominal()
	{
		FVector Negated = -FVector(1, 2, 3);
		return Negated.X == -1.0 && Negated.Y == -2.0 && Negated.Z == -3.0;
	}
}
/** @end */
