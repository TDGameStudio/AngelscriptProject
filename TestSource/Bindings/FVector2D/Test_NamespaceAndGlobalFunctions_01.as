// Purpose: Observe FVector2D zero and unit-component constants.
// AS-facing API: const FVector2D FVector2D::ZeroVector;
// const FVector2D FVector2D::UnitVector;
// Inputs: Each published constant compared against (0,0) and (1,1).
// Expected observations: ZeroVector is (0,0). UnitVector is (1,1).
// Boundary/ownership: Constants are shared values, not factory functions.

namespace TS_FVector2D_NamespaceAndGlobalFunctions_01
{
	// FVector2D::ZeroVector is (0,0). Shared constant.
	bool Observe_Surface046_Nominal()
	{
		return FVector2D::ZeroVector.X == 0.0 && FVector2D::ZeroVector.Y == 0.0;
	}

	// FVector2D::UnitVector is (1,1). Shared constant.
	bool Observe_Surface047_Nominal()
	{
		return FVector2D::UnitVector.X == 1.0 && FVector2D::UnitVector.Y == 1.0;
	}
}
