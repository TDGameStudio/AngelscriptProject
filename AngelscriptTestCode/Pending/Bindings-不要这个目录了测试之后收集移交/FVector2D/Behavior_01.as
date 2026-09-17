/**
 * @version v1
 * @summary Observe FVector2D constructors, XY fields, negation, 2D cross/dot, and Size.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2D constructors, XY fields, negation, 2D cross/dot, and Size.
 * @topic Baseline
 */
// X; Y; -Vector; CrossProduct; DotProduct; Size.
// Inputs: (3,4) so Size is 5, default zero, copy, FVector2f(7,8).
// Expected observations: Default is (0,0). Copy preserves (3,4). FVector2f
// conversion keeps 7/8. Cross of (1,0) and (0,1) is 1. Dot of those is 0.
// Size of (3,4) is 5. Negation flips signs.
// Boundary/ownership: 2D CrossProduct is a scalar. Constructors copy values.

namespace TS_FVector2D_Behavior_01
{
	// FVector2D(X,Y), default, copy, FVector2f: default is zero; copy and conversion keep components.
	bool Observe_Vector_Nominal()
	{
		FVector2D Explicit(3, 4);
		FVector2D Zero;
		FVector2D Copied(Explicit);
		FVector2D FromFloat(FVector2f(7, 8));
		return Explicit.Y == 4.0 && Zero.IsZero() && Copied.X == 3.0 && FromFloat.X == 7.0 && FromFloat.Y == 8.0;
	}

	// FVector2D.X of (3,4) is 3. Field read, no mutation.
	bool Observe_Surface006_Nominal()
	{
		return FVector2D(3, 4).X == 3.0;
	}

	// FVector2D.Y of (3,4) is 4. Field read, no mutation.
	bool Observe_Surface007_Nominal()
	{
		return FVector2D(3, 4).Y == 4.0;
	}

	// Unary minus of (3,4) is (-3,-4). Returns a new vector.
	bool Observe_Surface017_Nominal()
	{
		FVector2D Negated = -FVector2D(3, 4);
		return Negated.X == -3.0 && Negated.Y == -4.0;
	}

	// 2D CrossProduct is a scalar: (1,0)x(0,1) is 1; reverse is -1.
	bool Observe_CrossProduct_Nominal()
	{
		float64 Cross = FVector2D(1, 0).CrossProduct(FVector2D(0, 1));
		float64 Reverse = FVector2D(0, 1).CrossProduct(FVector2D(1, 0));
		return Cross == 1.0 && Reverse == -1.0;
	}

	// DotProduct: orthogonal axes are 0; aligned X is 1.
	bool Observe_DotProduct_Nominal()
	{
		float64 Orthogonal = FVector2D(1, 0).DotProduct(FVector2D(0, 1));
		float64 Aligned = FVector2D(1, 0).DotProduct(FVector2D(1, 0));
		return Orthogonal == 0.0 && Aligned == 1.0;
	}

	// Size of (3,4) is 5; zero size is 0.
	bool Observe_Size_Nominal()
	{
		return FVector2D(3, 4).Size() == 5.0 && FVector2D(0, 0).Size() == 0.0;
	}
}
/** @end */
