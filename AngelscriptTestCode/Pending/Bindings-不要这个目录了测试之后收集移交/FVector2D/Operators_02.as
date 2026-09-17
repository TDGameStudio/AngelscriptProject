/**
 * @version v1
 * @summary Observe FVector2D equality and string concatenation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2D equality and string concatenation.
 * @topic Baseline
 */
// Text + Vector is longer than the prefix. Source vector is unchanged.
// Boundary/ownership: Equality is exact. Concatenation returns a new FString.

namespace TS_FVector2D_Operators_02
{
	bool Observe_Equality_Nominal()
	{
		FVector2D Left(2, 4);
		FVector2D Right(2, 4);
		FVector2D Different(2, 5);
		return (Left == Right) && !(Left == Different);
	}

	bool Observe_Addition_Nominal()
	{
		FVector2D Vector(2, 4);
		FString Combined = FString("v:") + Vector;
		return Combined.Len() > 2 && Vector.X == 2.0;
	}
}
/** @end */
