// Purpose: Observe FBoxSphereBounds3f union and formatter interpolation.
// The bool return is the runner-readable oracle.
// AS-facing API: FBoxSphereBounds3f Combined = Left + Right; FString Text = f"{Bounds}";
// Inputs: Left origin 0 extent 1 radius 1, Right origin 2, copied Left.
// Expected observations: Combined radius is at least Left's radius. Left is
// unchanged. Formatted text is non-empty.
// Boundary/ownership: + returns a new single-precision bounds.

namespace TS_FBoxSphereBounds3f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FBoxSphereBounds3f Left(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Right(FVector3f(2, 0, 0), FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Original = Left;
		FBoxSphereBounds3f Combined = Left + Right;
		FString Text = f"{Combined}";
		return Combined.SphereRadius >= Original.SphereRadius && Left.Origin.X == 0.0 && Text.Len() > 0;
	}
}
