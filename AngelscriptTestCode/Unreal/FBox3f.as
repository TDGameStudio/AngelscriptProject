/**
 * @version v1
 * @summary FBox3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBox3f
 *
 * box
 * surface-005
 * surface-006
 * intersect
 * inverse-transform-by
 * transform-by
 * struct-fbox3f
 * add-assign
 * to-string
 * append
 * build-aabb
 * addition
 * equality
 * index
 * get-center
 * get-extent
 * get-center-and-extents
 * get-closest-point-to
 * is-inside
 * is-inside-or-on
 */
/**
 * @begin box
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveBoxNominal
 * @summary Observe the container API.
 * @covers FBox3f.box
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FBox3f Box(const FBox& Box); Min; Max; Intersect; InverseTransformBy;
// TransformBy(FTransform3f).
// Inputs: Default box, (0,0,0)-(2,2,2), FBox conversion, overlapping and
// disjoint neighbors, identity transforms.
// Expected observations: Conversion preserves 2.0 max. Identity transforms
// preserve corners. Overlapping Intersect is true.
// Boundary/ownership: Transform helpers return new boxes.
// FBox3f() default, corner (0,0,0)-(2,2,2), and FBox conversion. Oracle: Max.X==2 on both constructed boxes. Value type.
bool ObserveBoxNominal()
{
	FBox3f DefaultBox;
	FBox3f Corners(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FBox DoubleBox(FVector(0, 0, 0), FVector(2, 2, 2));
	FBox3f FromDouble(DoubleBox);
	return Corners.Max.X == 2.0 && FromDouble.Max.X == 2.0 && !(DefaultBox == Corners);
}
/** @end */
/**
 * @begin surface-005
 * @summary FBox3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FBox3f.
 * @covers FBox3f.surface-005
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

Min on (0,0,0)-(2,2,2). Oracle: Min.X==0. Field read does not mutate.
bool ObserveSurface005Nominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	return Box.Min.X == 0.0;
}
/** @end */
/**
 * @begin surface-006
 * @summary FBox3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FBox3f.
 * @covers FBox3f.surface-006
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

Max on (0,0,0)-(2,2,2). Oracle: Max.X==2. Field read does not mutate.
bool ObserveSurface006Nominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	return Box.Max.X == 2.0;
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
 * @covers FBox3f.intersect
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Intersect overlapping (1,1,1)-(3,3,3) vs disjoint (5,5,5)-(6,6,6). Oracle: true then false. No mutation.
bool ObserveIntersectNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FBox3f Overlap(FVector3f(1, 1, 1), FVector3f(3, 3, 3));
	FBox3f Disjoint(FVector3f(5, 5, 5), FVector3f(6, 6, 6));
	return Box.Intersect(Overlap) && !Box.Intersect(Disjoint);
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
 * @covers FBox3f.inverse-transform-by
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseTransformByNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FBox3f Inverted = Box.InverseTransformBy(FTransform::Identity);
	return Inverted.Max.X == 2.0 && Box.Max.X == 2.0;
}
/** @end */
/**
 * @begin transform-by
 * @summary TransformBy(FTransform3f::Identity) on (0,0,0)-(2,2,2).
 * @topic Unreal
 */
/**
 * @function ObserveTransformByNominal
 * @summary TransformBy(FTransform3f::Identity) on (0,0,0)-(2,2,2).
 * @covers FBox3f.transform-by
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformByNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FBox3f Transformed = Box.TransformBy(FTransform3f::Identity);
	return Transformed.Max.X == 2.0 && Box.Max.X == 2.0;
}
/** @end */
/**
 * @begin struct-fbox3f
 * @summary struct FBox3f
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary struct FBox3f
 * @covers FBox3f.struct-fbox3f
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
 constructed as (0,0,0)-(1,1,1). Oracle: Max.X==1. Value type declaration.
bool ObserveSurface001Nominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	return Box.Max.X == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Box += OtherBox then += Point then Text += Box.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Box += OtherBox then += Point then Text += Box.
 * @covers FBox3f.add-assign
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FBox3f Other(FVector3f(1, 1, 1), FVector3f(2, 2, 2));
	Box += Other;
	FVector3f Point(3, 3, 3);
	Box += Point;
	FString Text = "box:";
	Text += Box;
	return Box.Max.X == 3.0 && Other.Max.X == 2.0 && Text.Len() > 4;
}
/** @end */
/**
 * @begin to-string
 * @summary Boundary/ownership: ToString returns a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary Boundary/ownership: ToString returns a new FString.
 * @covers FBox3f.to-string
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FString Text = Box.ToString();
	FBox3f Degenerate(FVector3f(0, 0, 0), FVector3f(0, 0, 0));
	FString DegenerateText = Degenerate.ToString();
	return Text.Len() > 0 && DegenerateText.Len() > 0 && Box.Max.X == 1.0;
}
/** @end */
/**
 * @begin append
 * @summary Boundary/ownership: Append copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary Boundary/ownership: Append copies formatted text.
 * @covers FBox3f.append
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
{
	FString Text = "box:";
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	int Before = Text.Len();
	Text.Append(Box);
	int AfterFirst = Text.Len();
	Text.Append(Box);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Box.Max.X == 1.0;
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
 * @covers FBox3f.build-aabb
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Origin (1,1,1), Extent (1,1,1), zero extent.
// Expected observations: Min is (0,0,0) and Max is (2,2,2). Zero extent is
// a point box at the origin.
// Boundary/ownership: Origin is the center. The factory returns a new box.
bool ObserveBuildAABBNominal()
{
	FBox3f Box = FBox3f::BuildAABB(FVector3f(1, 1, 1), FVector3f(1, 1, 1));
	FBox3f Degenerate = FBox3f::BuildAABB(FVector3f(1, 1, 1), FVector3f(0, 0, 0));
	return Box.Min.X == 0.0 && Box.Max.X == 2.0 && Degenerate.Min.X == 1.0 && Degenerate.Max.X == 1.0;
}
/** @end */
/**
 * @begin addition
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Observe the container API.
 * @covers FBox3f.addition
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Identical (0,0,0)-(1,1,1), different max, point (2,2,2), index 0/1,
// prefix "box:".
// Expected observations: + of boxes grows the copy. == is true for identical
// corners. Box[0] is Min. Text + Box is longer than the prefix.
// Boundary/ownership: + does not mutate Box. Invalid index is the diagnostic
// path.
bool ObserveAdditionNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FBox3f Other(FVector3f(1, 1, 1), FVector3f(2, 2, 2));
	FBox3f Union = Box + Other;
	FBox3f Expanded = Box + FVector3f(2, 2, 2);
	FString Combined = FString("box:") + Box;
	return Union.Max.X == 2.0 && Expanded.Max.X == 2.0 && Combined.Len() > 4 && Box.Max.X == 1.0;
}
/** @end */
/**
 * @begin equality
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary path.
 * @covers FBox3f.equality
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualityNominal()
{
	FBox3f Left(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FBox3f Right(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FBox3f Different(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	return (Left == Right) && !(Left == Different);
}
/** @end */
/**
 * @begin index
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary path.
 * @covers FBox3f.index
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIndexNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
	FVector3f MinCorner = Box[0];
	FVector3f MaxCorner = Box[1];
	return MinCorner.X == 0.0 && MaxCorner.X == 1.0;
}
/** @end */
/**
 * @begin get-center
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetCenterNominal
 * @summary Observe the container API.
 * @covers FBox3f.get-center
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Box (0,0,0)-(2,2,2), interior (1,1,1), on-face (0,1,1), exterior
// (3,1,1).
// Expected observations: Center/extent are (1,1,1). Closest exterior point
// clamps to 2. Interior IsInside true; on-face IsInsideOrOn true.
// Boundary/ownership: Out Center/Extents are writebacks.
bool ObserveGetCenterNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FVector3f Center = Box.GetCenter();
	return Center.X == 1.0;
}
/** @end */
/**
 * @begin get-extent
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetExtentNominal
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @covers FBox3f.get-extent
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetExtentNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FVector3f Extent = Box.GetExtent();
	return Extent.X == 1.0;
}
/** @end */
/**
 * @begin get-center-and-extents
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetCenterAndExtentsNominal
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @covers FBox3f.get-center-and-extents
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetCenterAndExtentsNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FVector3f Center;
	FVector3f Extents;
	Box.GetCenterAndExtents(Center, Extents);
	return Center.X == 1.0 && Extents.X == 1.0;
}
/** @end */
/**
 * @begin get-closest-point-to
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetClosestPointToNominal
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @covers FBox3f.get-closest-point-to
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetClosestPointToNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FVector3f Outside = Box.GetClosestPointTo(FVector3f(3, 1, 1));
	return Outside.X == 2.0;
}
/** @end */
/**
 * @begin is-inside
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideNominal
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @covers FBox3f.is-inside
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	return Box.IsInside(FVector3f(1, 1, 1)) && !Box.IsInside(FVector3f(3, 1, 1));
}
/** @end */
/**
 * @begin is-inside-or-on
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideOrOnNominal
 * @summary Boundary/ownership: Out Center/Extents are writebacks.
 * @covers FBox3f.is-inside-or-on
 * @inputs FBox3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsInsideOrOnNominal()
{
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	return Box.IsInsideOrOn(FVector3f(0, 1, 1)) && !Box.IsInsideOrOn(FVector3f(3, 1, 1));
}
/** @end */
