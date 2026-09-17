/**
 * @version v1
 * @summary Observe FVector2f type declaration, constructors, XY fields, and 2D cross/dot products.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f type declaration, constructors, XY fields, and 2D cross/dot products.
 * @topic Baseline
 */
// Value(FVector3f); Value(FVector2D); X; Y; CrossProduct; DotProduct.
// Inputs: Default/zero, (3,4), copy, FVector3f(7,8,9) discarding Z,
// FVector2D(5,6).
// Expected observations: Default is (0,0). Copy preserves (3,4). FVector3f
// conversion keeps XY and drops 9. FVector2D conversion keeps 5/6. Cross of
// (1,0) and (0,1) is 1. Dot of those is 0.
// Boundary/ownership: Components are float32. FVector3f conversion discards
// Z. Constructors copy values.

namespace TS_FVector2f_Behavior_01
{
	// FVector2f Value; default construction is (0,0). Declaration, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FVector2f Value;
		return Value.X == 0.0f && Value.Y == 0.0f;
	}

	// FVector2f constructors: copy, FVector3f (drops Z), FVector2D. Default is zero.
	bool Observe_Value_Nominal()
	{
		FVector2f Explicit(3.0f, 4.0f);
		FVector2f Zero;
		FVector2f Copied(Explicit);
		FVector2f From3(FVector3f(7.0f, 8.0f, 9.0f));
		FVector2f FromDouble(FVector2D(5, 6));
		return Explicit.Y == 4.0f &&
			Zero.IsZero() &&
			Copied.X == 3.0f &&
			From3.X == 7.0f &&
			From3.Y == 8.0f &&
			FromDouble.X == 5.0f &&
			FromDouble.Y == 6.0f;
	}

	// FVector2f.X of (3,4) is 3. Field read, no mutation.
	bool Observe_Surface007_Nominal()
	{
		return FVector2f(3.0f, 4.0f).X == 3.0f;
	}

	// FVector2f.Y of (3,4) is 4. Field read, no mutation.
	bool Observe_Surface008_Nominal()
	{
		return FVector2f(3.0f, 4.0f).Y == 4.0f;
	}

	// 2D CrossProduct is a scalar: (1,0)x(0,1) is 1; reverse is -1.
	bool Observe_CrossProduct_Nominal()
	{
		float32 Cross = FVector2f(1.0f, 0.0f).CrossProduct(FVector2f(0.0f, 1.0f));
		float32 Reverse = FVector2f(0.0f, 1.0f).CrossProduct(FVector2f(1.0f, 0.0f));
		return Cross == 1.0f && Reverse == -1.0f;
	}

	// DotProduct: orthogonal axes are 0; aligned X is 1.
	bool Observe_DotProduct_Nominal()
	{
		float32 Orthogonal = FVector2f(1.0f, 0.0f).DotProduct(FVector2f(0.0f, 1.0f));
		float32 Aligned = FVector2f(1.0f, 0.0f).DotProduct(FVector2f(1.0f, 0.0f));
		return Orthogonal == 0.0f && Aligned == 1.0f;
	}
}
/** @end */
