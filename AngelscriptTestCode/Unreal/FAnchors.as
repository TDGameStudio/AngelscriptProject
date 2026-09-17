/**
 * @version v1
 * @summary FAnchors host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FAnchors
 *
 * anchors
 * equality
 * is-stretched-horizontal
 */
/**
 * @begin anchors
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveAnchorsNominal
 * @summary AS-facing API:
 * @covers FAnchors.anchors
 * @inputs FAnchors values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 FAnchors Anchors(float32 UnifromAnchors);
// FAnchors Anchors(float32 Horizontal, float32 Vertical);
// FAnchors Anchors(float32 MinX, float32 MinY, float32 MaxX, float32 MaxY);
// Inputs: Uniform 0.5, point (0.25, 0.75), range (0,0,1,1), and uniform 0.0
// as the empty coordinate.
// Expected observations: Uniform 0.5 is not stretched. Range (0,0,1,1) is
// stretched on both axes. Point constructor equals a range with min==max.
// Boundary/ownership: UniformAnchors is shared on both axes. Values are
// normalized widget coordinates, not pixels.
bool ObserveAnchorsNominal()
{
	FAnchors Uniform(0.5);
	FAnchors Point(0.25, 0.75);
	FAnchors Range(0.0, 0.0, 1.0, 1.0);
	FAnchors Zero(0.0);
	FAnchors PointAsRange(0.25, 0.75, 0.25, 0.75);
	return !Uniform.IsStretchedHorizontal() && !Uniform.IsStretchedVertical() && Range.IsStretchedHorizontal() && Range.IsStretchedVertical() && Point == PointAsRange && !Zero.IsStretchedHorizontal();
}
/** @end */
/**
 * @begin equality
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Observe the container API.
 * @covers FAnchors.equality
 * @inputs FAnchors values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Identical (0.5, 0.5) point anchors, a stretched (0,0,1,1) range,
// and a zero uniform 0.0 anchor.
// Expected observations: Identical constructors compare true. Point vs
// stretched range is false. Equality does not mutate either operand.
// Boundary/ownership: Comparison is by all four min/max coordinates.
bool ObserveEqualityNominal()
{
	FAnchors Left(0.5, 0.5);
	FAnchors Right(0.5, 0.5);
	FAnchors Stretched(0.0, 0.0, 1.0, 1.0);
	FAnchors Zero(0.0);
	return Left == Right && !(Left == Stretched) && !(Left == Zero);
}
/** @end */
/**
 * @begin is-stretched-horizontal
 * @summary mutate the anchors.
 * @topic Unreal
 */
/**
 * @function ObserveIsStretchedHorizontalNominal
 * @summary mutate the anchors.
 * @covers FAnchors.is-stretched-horizontal
 * @inputs FAnchors values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveIsStretchedHorizontalNominal()
{
	FAnchors Point(0.5, 0.5);
	FAnchors Full(0.0, 0.0, 1.0, 1.0);
	FAnchors HorizontalOnly(0.0, 0.5, 1.0, 0.5);
	return !Point.IsStretchedHorizontal() && Full.IsStretchedHorizontal() && HorizontalOnly.IsStretchedHorizontal();
}
/** @end */
