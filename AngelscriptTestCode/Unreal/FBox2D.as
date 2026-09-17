/**
 * @version v1
 * @summary FBox2D host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBox2D
 *
 * box
 * expand-by
 * is-inside
 */
/**
 * @begin box
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveBoxNominal
 * @summary AS-facing API:
 * @covers FBox2D.box
 * @inputs FBox2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 FBox2D Box(const FVector2D& InMin, const FVector2D& InMax);
// FBox2D FBox2D.ExpandBy(float64 Amount) const;
// Inputs: (0,0)-(2,2), Amount 1.0 and 0.0.
// Expected observations: Constructor stores min/max. ExpandBy(1) grows both
// corners. ExpandBy(0) preserves the box. The source box is unchanged.
// Boundary/ownership: ExpandBy returns a new box.
bool ObserveBoxNominal()
{
	FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
	return Box.Min.X == 0.0 && Box.Max.X == 2.0;
}
/** @end */
/**
 * @begin expand-by
 * @summary Boundary/ownership: ExpandBy returns a new box.
 * @topic Unreal
 */
/**
 * @function ObserveExpandByNominal
 * @summary Boundary/ownership: ExpandBy returns a new box.
 * @covers FBox2D.expand-by
 * @inputs FBox2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveExpandByNominal()
{
	FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
	FBox2D Expanded = Box.ExpandBy(1.0);
	FBox2D Zero = Box.ExpandBy(0.0);
	return Expanded.Min.X == -1.0 && Expanded.Max.X == 3.0 && Zero.Min.X == 0.0 && Zero.Max.X == 2.0 && Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin is-inside
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideNominal
 * @summary Observe the container API.
 * @covers FBox2D.is-inside
 * @inputs FBox2D values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Box (0,0)-(2,2), interior (1,1), exterior (3,1), and on-edge (0,1).
// Expected observations: Interior is true. Exterior is false. On-edge min is
// excluded because native IsInside is open on both bounds.
// Boundary/ownership: IsInside does not mutate the box.
bool ObserveIsInsideNominal()
{
	FBox2D Box(FVector2D(0, 0), FVector2D(2, 2));
	return Box.IsInside(FVector2D(1, 1)) && !Box.IsInside(FVector2D(3, 1)) && !Box.IsInside(FVector2D(0, 1));
}
/** @end */
