/**
 * @version v1
 * @summary Observe FVector3f constructors, XYZ fields, cross/dot products, and AllComponentsEqual.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f constructors, XYZ fields, cross/dot products, and AllComponentsEqual.
 * @topic Baseline
 */
// CrossProduct; DotProduct; AllComponentsEqual.
// Inputs: (1,2,3), default zero, uniform 7, copy, unit X/Y, (1,1,1), (1,2,1).
// Expected observations: Default is (0,0,0). Uniform 7 fills all axes. Copy
// preserves (1,2,3). X cross Y is Z. X dot Y is 0. (1,1,1) components are
// equal.
// Boundary/ownership: Constructors copy values. Components are float32.
// AllComponentsEqual uses __KINDA_SMALL_NUMBER_flt.

namespace TS_FVector3f_Behavior_01
{
	// FVector3f(X,Y,Z), default, uniform, and copy constructors. Components are float32 copies.
	bool Observe_Vector_Nominal()
	{
		FVector3f Explicit(1.0f, 2.0f, 3.0f);
		FVector3f Zero;
		FVector3f Uniform(7.0f);
		FVector3f Copied(Explicit);
		return Explicit.Z == 3.0f && Zero.IsZero() && Uniform.Y == 7.0f && Copied.X == 1.0f;
	}

	// FVector3f.X of (1,2,3) is 1. Field read does not mutate.
	bool Observe_Surface005_Nominal()
	{
		return FVector3f(1.0f, 2.0f, 3.0f).X == 1.0f;
	}

	// FVector3f.Y of (1,2,3) is 2. Field read does not mutate.
	bool Observe_Surface006_Nominal()
	{
		return FVector3f(1.0f, 2.0f, 3.0f).Y == 2.0f;
	}

	// FVector3f.Z of (1,2,3) is 3. Field read does not mutate.
	bool Observe_Surface007_Nominal()
	{
		return FVector3f(1.0f, 2.0f, 3.0f).Z == 3.0f;
	}

	// CrossProduct of unit X and unit Y is unit Z. Returns a new vector.
	bool Observe_CrossProduct_Nominal()
	{
		FVector3f Cross = FVector3f(1.0f, 0.0f, 0.0f).CrossProduct(FVector3f(0.0f, 1.0f, 0.0f));
		return Cross.Equals(FVector3f(0.0f, 0.0f, 1.0f));
	}

	// DotProduct of orthogonal unit axes is 0; aligned unit X is 1.
	bool Observe_DotProduct_Nominal()
	{
		float32 Orthogonal = FVector3f(1.0f, 0.0f, 0.0f).DotProduct(FVector3f(0.0f, 1.0f, 0.0f));
		float32 Aligned = FVector3f(1.0f, 0.0f, 0.0f).DotProduct(FVector3f(1.0f, 0.0f, 0.0f));
		return Orthogonal == 0.0f && Aligned == 1.0f;
	}

	// AllComponentsEqual is true for (1,1,1) and false for (1,2,1).
	bool Observe_AllComponentsEqual_Nominal()
	{
		return FVector3f(1.0f, 1.0f, 1.0f).AllComponentsEqual() && !FVector3f(1.0f, 2.0f, 1.0f).AllComponentsEqual();
	}
}
/** @end */
