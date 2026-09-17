/**
 * @version v1
 * @summary Observe FBoxSphereBounds union and formatter interpolation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBoxSphereBounds union and formatter interpolation.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBoxSphereBounds Combined = Left + Right; FString Text = f"{Bounds}";
// Inputs: Left origin 0 extent 1 radius 1, Right origin 2 extent 1 radius 1,
// and a copy of Left.
// Expected observations: Combined sphere radius is at least 1. Left is
// unchanged. f"{Bounds}" is non-empty.
// Boundary/ownership: + returns a new bounds. The formatter copies text.

namespace TS_FBoxSphereBounds_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FBoxSphereBounds Left(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Right(FVector(2, 0, 0), FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Original = Left;
		FBoxSphereBounds Combined = Left + Right;
		FString Text = f"{Combined}";
		return Combined.SphereRadius >= Original.SphereRadius && Left.Origin.X == 0.0 && Text.Len() > 0;
	}
}
/** @end */
