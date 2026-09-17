/**
 * @version v1
 * @summary Observe FBox2D construction from corners and ExpandBy.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox2D construction from corners and ExpandBy.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBox2D Box(const FVector2D& InMin, const FVector2D& InMax);
// FBox2D FBox2D.ExpandBy(float64 Amount) const;
// Inputs: (0,0)-(2,2), Amount 1.0 and 0.0.
// Expected observations: Constructor stores min/max. ExpandBy(1) grows both
// corners. ExpandBy(0) preserves the box. The source box is unchanged.
// Boundary/ownership: ExpandBy returns a new box.

namespace TS_FBox2D_Behavior_01
{
	bool Observe_Box_Nominal()
	{
		FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
		return Box.Min.X == 0.0 && Box.Max.X == 2.0;
	}

	bool Observe_ExpandBy_Nominal()
	{
		FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
		FBox2D Expanded = Box.ExpandBy(1.0);
		FBox2D Zero = Box.ExpandBy(0.0);
		return Expanded.Min.X == -1.0 && Expanded.Max.X == 3.0 && Zero.Min.X == 0.0 && Zero.Max.X == 2.0 && Box.Min.X == 0.0;
	}
}
/** @end */
