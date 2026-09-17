/**
 * @version v1
 * @summary FBox host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBox
 *
 * box
 * surface-004
 * surface-005
 * inverse-transform-by
 * transform-by
 * intersect
 * intersect-xy
 * overlap
 * expand-by
 * shift-by
 * move-to
 * assignment
 * add-assign
 * build-aabb
 * equality
 * index
 * get-extent
 * get-volume
 * get-center-and-extents
 * get-closest-point-to
 * equals
 * is-inside
 * is-inside-or-on
 * is-inside-xy
 * is-inside-or-on-xy
 * FBox-Queries_02-is-inside-xy
 */
/**
 * @begin box
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveBoxNominal
 * @summary Observe the container API.
 * @covers FBox.box
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FBox Box(const FBox3f& Box); FVector Box.Min; FVector Box.Max;
// InverseTransformBy; TransformBy; Intersect; IntersectXY; Overlap.
// Inputs: Default/invalid box, (0,0,0)-(2,2,2), FBox3f conversion, identity
// transform, overlapping and disjoint neighbors.
// Expected observations: Corner constructor stores Min/Max. Identity
// transform preserves the box. Overlapping Intersect is true; disjoint is
// false. Overlap of overlapping boxes has positive volume.
// Boundary/ownership: Default Box() is invalid/force-initialized. Transform
// returns a new box.
// FBox() default, corner (0,0,0)-(2,2,2), and FBox3f conversion. Oracle: stored Min/Max and converted Max.X==1. Value type.
bool ObserveBoxNominal()
{
	FBox DefaultBox;
	FBox Corners(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox3f Single(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FBox FromSingle(Single);
	return Corners.Min.X == 0.0 && Corners.Max.X == 2.0 && FromSingle.Max.X == 1.0 && !(DefaultBox == Corners);
}
/** @end */
/**
 * @begin surface-004
 * @summary FBox.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary FBox.
 * @covers FBox.surface-004
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

Min on (0,0,0)-(2,2,2). Oracle: Min.X==0. Field read does not mutate.
bool ObserveSurface004Nominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FVector Min = Box.Min;
	return Min.X == 0.0 && Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin surface-005
 * @summary FBox.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FBox.
 * @covers FBox.surface-005
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

Max on (0,0,0)-(2,2,2). Oracle: Max.X==2. Field read does not mutate.
bool ObserveSurface005Nominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FVector Max = Box.Max;
	return Max.X == 2.0 && Box.Max.X == 2.0;
}
/** @end */
/**
 * @begin inverse-transform-by
 * @summary InverseTransformBy(Identity) on (0,0,0)-(2,2,2).
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformByNominal
 * @summary InverseTransformBy(Identity) on (0,0,0)-(2,2,2).
 * @covers FBox.inverse-transform-by
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseTransformByNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Inverted = Box.InverseTransformBy(FTransform::Identity);
	return Inverted.Min.X == 0.0 && Inverted.Max.X == 2.0 && Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin transform-by
 * @summary TransformBy(Identity) on (0,0,0)-(2,2,2).
 * @topic Unreal
 */
/**
 * @function ObserveTransformByNominal
 * @summary TransformBy(Identity) on (0,0,0)-(2,2,2).
 * @covers FBox.transform-by
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformByNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Transformed = Box.TransformBy(FTransform::Identity);
	return Transformed.Min.X == 0.0 && Transformed.Max.X == 2.0 && Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin intersect
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveIntersectNominal
 * @summary Observe the container API.
 * @covers FBox.intersect
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Intersect overlapping (1,1,1)-(3,3,3) vs disjoint (5,5,5)-(6,6,6). Oracle: true then false. No mutation.
bool ObserveIntersectNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Overlap(FVector(1, 1, 1), FVector(3, 3, 3));
	FBox Disjoint(FVector(5, 5, 5), FVector(6, 6, 6));
	return Box.Intersect(Overlap) && !Box.Intersect(Disjoint);
}
/** @end */
/**
 * @begin intersect-xy
 * @summary IntersectXY
 * @topic Unreal
 */
/**
 * @function ObserveIntersectXYNominal
 * @summary IntersectXY
 * @covers FBox.intersect-xy
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 overlapping XY (1,1,9)-(3,3,10) vs disjoint XY. Oracle: true then false. Z ignored.
bool ObserveIntersectXYNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox OverlapXY(FVector(1, 1, 9), FVector(3, 3, 10));
	FBox DisjointXY(FVector(5, 5, 0), FVector(6, 6, 1));
	return Box.IntersectXY(OverlapXY) && !Box.IntersectXY(DisjointXY);
}
/** @end */
/**
 * @begin overlap
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveOverlapNominal
 * @summary Observe the container API.
 * @covers FBox.overlap
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Overlap of (0,0,0)-(2,2,2) and (1,1,1)-(3,3,3). Oracle: volume > 0. Returns a new box.
bool ObserveOverlapNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Other(FVector(1, 1, 1), FVector(3, 3, 3));
	FBox Overlap = Box.Overlap(Other);
	return Overlap.GetVolume() > 0.0 && Box.GetVolume() == 8.0;
}
/** @end */
/**
 * @begin expand-by
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveExpandByNominal
 * @summary Observe the container API.
 * @covers FBox.expand-by
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Box (0,0,0)-(2,2,2), W=1, V=(1,0,0), Offset=(1,0,0), Destination
// (5,5,5), and W=0 as the empty expansion.
// Expected observations: ExpandBy(1) grows extent. ShiftBy moves both corners
// equally. MoveTo places the center at Destination. W=0 preserves the box.
// Boundary/ownership: These helpers return new boxes and do not mutate the
// receiver.
bool ObserveExpandByNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Uniform = Box.ExpandBy(1.0);
	FBox Axis = Box.ExpandBy(FVector(1, 0, 0));
	FBox Zero = Box.ExpandBy(0.0);
	return Uniform.Min.X == -1.0 && Uniform.Max.X == 3.0 && Axis.Min.X == -1.0 && Axis.Max.Y == 2.0 && Zero == Box;
}
/** @end */
/**
 * @begin shift-by
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveShiftByNominal
 * @summary receiver.
 * @covers FBox.shift-by
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveShiftByNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Shifted = Box.ShiftBy(FVector(1, 0, 0));
	return Shifted.Min.X == 1.0 && Shifted.Max.X == 3.0 && Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin move-to
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveMoveToNominal
 * @summary receiver.
 * @covers FBox.move-to
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveMoveToNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Moved = Box.MoveTo(FVector(5, 5, 5));
	FVector Center = Moved.GetCenter();
	return Center.X == 5.0 && Center.Y == 5.0 && Center.Z == 5.0 && Box.GetCenter().X == 1.0;
}
/** @end */
/**
 * @begin assignment
 * @summary expansion includes 3.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary expansion includes 3.
 * @covers FBox.assignment
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 copy stays (1,1,1).
// Boundary/ownership: + returns a new box. += mutates the left operand.
bool ObserveAssignmentNominal()
{
	FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Right(FVector(1, 1, 1), FVector(2, 2, 2));
	FBox Original = Left;
	FBox Union = Left + Right;
	FString Text = f"{Union}";
	return Union.Max.X == 2.0 && Original.Max.X == 1.0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Boundary/ownership: + returns a new box.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Boundary/ownership: + returns a new box.
 * @covers FBox.add-assign
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAddAssignNominal()
{
	FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Right(FVector(1, 1, 1), FVector(2, 2, 2));
	Left += Right;
	FBox Box(FVector(0, 0, 0), FVector(1, 1, 1));
	FVector Point(3, 3, 3);
	FBox Expanded = Box + Point;
	Box += Point;
	return Left.Max.X == 2.0 && Right.Max.X == 2.0 && Expanded.Max.X == 3.0 && Box.Max.X == 3.0;
}
/** @end */
/**
 * @begin build-aabb
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveBuildAABBNominal
 * @summary Observe the container API.
 * @covers FBox.build-aabb
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Origin (1,1,1), Extent (1,1,1), and ZeroVector extent as the empty
// volume case.
// Expected observations: Result min is (0,0,0) and max is (2,2,2). Zero
// extent yields min==max at the origin.
// Boundary/ownership: BuildAABB returns a new box. Origin is the center, not
// a corner.
bool ObserveBuildAABBNominal()
{
	FBox Box = FBox::BuildAABB(FVector(1, 1, 1), FVector(1, 1, 1));
	FBox Degenerate = FBox::BuildAABB(FVector(1, 1, 1), FVector::ZeroVector);
	return Box.Min.X == 0.0 && Box.Max.X == 2.0 && Degenerate.Min.X == 1.0 && Degenerate.Max.X == 1.0;
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
 * @covers FBox.equality
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Identical (0,0,0)-(1,1,1) boxes, a different max, index 0/1, and
// an invalid index as the diagnostic path.
// Expected observations: Identical boxes compare true. Box[0] aliases Min and
// writing through it is visible on Box.Min. Box[1] is Max.
// Boundary/ownership: Index 0 is Min, 1 is Max. Native bounds behavior applies
// for other indices.
bool ObserveEqualityNominal()
{
	FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Right(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Different(FVector(0, 0, 0), FVector(2, 2, 2));
	return Left == Right && !(Left == Different);
}
/** @end */
/**
 * @begin index
 * @summary for other indices.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary for other indices.
 * @covers FBox.index
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIndexNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(1, 1, 1));
	FVector MinCorner = Box[0];
	FVector MaxCorner = Box[1];
	Box[0] = FVector(-1, -1, -1);
	return MinCorner.X == 0.0 && MaxCorner.X == 1.0 && Box.Min.X == -1.0;
}
/** @end */
/**
 * @begin get-extent
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveGetExtentNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.get-extent
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetExtentNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FVector Extent = Box.GetExtent();
	return Extent.X == 1.0 && Extent.Y == 1.0 && Extent.Z == 1.0;
}
/** @end */
/**
 * @begin get-volume
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveGetVolumeNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.get-volume
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetVolumeNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Flat(FVector(0, 0, 0), FVector(2, 2, 0));
	return Box.GetVolume() == 8.0 && Flat.GetVolume() == 0.0;
}
/** @end */
/**
 * @begin get-center-and-extents
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveGetCenterAndExtentsNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.get-center-and-extents
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetCenterAndExtentsNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FVector Center = FVector::ZeroVector;
	FVector Extents = FVector::ZeroVector;
	Box.GetCenterAndExtents(Center, Extents);
	return Center.X == 1.0 && Extents.X == 1.0;
}
/** @end */
/**
 * @begin get-closest-point-to
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveGetClosestPointToNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.get-closest-point-to
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetClosestPointToNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FVector Inside = Box.GetClosestPointTo(FVector(1, 1, 1));
	FVector Outside = Box.GetClosestPointTo(FVector(3, 1, 1));
	return Inside.X == 1.0 && Outside.X == 2.0;
}
/** @end */
/**
 * @begin equals
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.equals
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualsNominal()
{
	FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Right(FVector(0, 0, 0), FVector(1, 1, 1));
	FBox Perturbed(FVector(0, 0, 0), FVector(1.0 + KINDA_SMALL_NUMBER * 0.5, 1, 1));
	return Left.Equals(Right) && Left.Equals(Perturbed);
}
/** @end */
/**
 * @begin is-inside
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.is-inside
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Inner(FVector(0.5, 0.5, 0.5), FVector(1.5, 1.5, 1.5));
	return Box.IsInside(FVector(1, 1, 1)) && !Box.IsInside(FVector(3, 1, 1)) && Box.IsInside(Inner);
}
/** @end */
/**
 * @begin is-inside-or-on
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideOrOnNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.is-inside-or-on
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideOrOnNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	return Box.IsInsideOrOn(FVector(0, 1, 1)) && !Box.IsInsideOrOn(FVector(3, 1, 1));
}
/** @end */
/**
 * @begin is-inside-xy
 * @summary tolerance, unlike operator==.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideXYNominal
 * @summary tolerance, unlike operator==.
 * @covers FBox.is-inside-xy
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideXYNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	return Box.IsInsideXY(FVector(1, 1, 9)) && !Box.IsInsideXY(FVector(3, 1, 1));
}
/** @end */
/**
 * @begin is-inside-or-on-xy
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideOrOnXYNominal
 * @summary Observe the container API.
 * @covers FBox.is-inside-or-on-xy
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Box (0,0,0)-(2,2,2), on-edge XY point (0,1,9), exterior XY (3,1,1),
// inner XY box, and a box that extends outside in XY.
// Expected observations: On-edge XY is inside-or-on. Exterior XY is false.
// Inner XY box is inside; overflowing XY box is not.
// Boundary/ownership: Z is ignored for XY tests. Queries do not mutate Box.
bool ObserveIsInsideOrOnXYNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	return Box.IsInsideOrOnXY(FVector(0, 1, 9)) && !Box.IsInsideOrOnXY(FVector(3, 1, 1));
}
/** @end */
/**
 * @begin FBox-Queries_02-is-inside-xy
 * @summary Boundary/ownership: Z is ignored for XY tests.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideXYNominal
 * @summary Boundary/ownership: Z is ignored for XY tests.
 * @covers FBox.is-inside-xy
 * @inputs FBox values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideXYNominal()
{
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox Inner(FVector(0.5, 0.5, 9), FVector(1.5, 1.5, 10));
	FBox Overflow(FVector(-1, 0.5, 0), FVector(1, 1, 1));
	return Box.IsInsideXY(Inner) && !Box.IsInsideXY(Overflow);
}
/** @end */
