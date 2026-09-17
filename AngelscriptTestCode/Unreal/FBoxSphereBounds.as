/**
 * @version v1
 * @summary FBoxSphereBounds host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBoxSphereBounds
 *
 * bounds
 * surface-008
 * fboxspherebounds-boxextent-origin
 * fboxspherebounds-sphereradius-origin-0
 * compute-squared-distance-from-box-to-point
 * expand-by
 * transform-by
 * assignment
 * spheres-intersect
 * boxes-intersect
 * equality
 * get-box
 * get-box-extrema
 * get-sphere
 */
/**
 * @begin bounds
 * @summary FBoxSphereBounds from parts, box, sphere, FBoxSphereBounds3f, and points.
 * @topic Unreal
 */
/**
 * @function ObserveBoundsNominal
 * @summary FBoxSphereBounds from parts, box, sphere, FBoxSphereBounds3f, and points.
 * @covers FBoxSphereBounds.bounds
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveBoundsNominal()
{
	FBoxSphereBounds DefaultBounds;
	FBoxSphereBounds FromParts(FVector(1, 1, 1), FVector(1, 1, 1), 2.0);
	FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
	FSphere Sphere(FVector(1, 1, 1), 2.0);
	FBoxSphereBounds FromBoxSphere(Box, Sphere);
	FBoxSphereBounds3f Single(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds FromSingle(Single);
	FBoxSphereBounds FromBox(Box);
	FBoxSphereBounds FromSphere(Sphere);
	TArray<FVector> Points;
	Points.Add(FVector::ZeroVector);
	Points.Add(FVector(2, 2, 2));
	FBoxSphereBounds FromPoints(Points);
	return FromParts.Origin.X == 1.0 && FromParts.SphereRadius == 2.0 && FromBox.SphereRadius > 0.0 && FromPoints.BoxExtent.X > 0.0 && FromSingle.SphereRadius > 0.0 && FromBoxSphere.SphereRadius > 0.0 && FromSphere.SphereRadius > 0.0 && DefaultBounds.SphereRadius == 0.0;
}
/** @end */
/**
 * @begin surface-008
 * @summary FBoxSphereBounds.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FBoxSphereBounds.
 * @covers FBoxSphereBounds.surface-008
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
Origin on (1,0,0) extent 1 radius 2. Oracle: Origin.X==1. Field read does not mutate.
bool ObserveSurface008Nominal()
{
	FBoxSphereBounds Bounds(FVector(1, 0, 0), FVector(1, 1, 1), 2.0);
	return Bounds.Origin.X == 1.0;
}
/** @end */
/**
 * @begin fboxspherebounds-boxextent-origin
 * @summary FBoxSphereBounds.BoxExtent on origin
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FBoxSphereBounds.BoxExtent on origin
 * @covers FBoxSphereBounds.fboxspherebounds-boxextent-origin
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
 0 extent (2,1,1). Oracle: BoxExtent.X==2. Field read does not mutate.
bool ObserveSurface009Nominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(2, 1, 1), 2.0);
	return Bounds.BoxExtent.X == 2.0;
}
/** @end */
/**
 * @begin fboxspherebounds-sphereradius-origin-0
 * @summary FBoxSphereBounds.SphereRadius on origin 0 radius 3.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FBoxSphereBounds.SphereRadius on origin 0 radius 3.
 * @covers FBoxSphereBounds.fboxspherebounds-sphereradius-origin-0
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 3.0);
	return Bounds.SphereRadius == 3.0;
}
/** @end */
/**
 * @begin compute-squared-distance-from-box-to-point
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveComputeSquaredDistanceFromBoxToPointNominal
 * @summary unchanged.
 * @covers FBoxSphereBounds.compute-squared-distance-from-box-to-point
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComputeSquaredDistanceFromBoxToPointNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	float64 Interior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector::ZeroVector);
	float64 Exterior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector(5, 0, 0));
	return Interior == 0.0 && Exterior > 0.0;
}
/** @end */
/**
 * @begin expand-by
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveExpandByNominal
 * @summary unchanged.
 * @covers FBoxSphereBounds.expand-by
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpandByNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	FBoxSphereBounds Expanded = Bounds.ExpandBy(1.0);
	FBoxSphereBounds Zero = Bounds.ExpandBy(0.0);
	return Expanded.SphereRadius > Bounds.SphereRadius && Zero.SphereRadius == 2.0;
}
/** @end */
/**
 * @begin transform-by
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveTransformByNominal
 * @summary unchanged.
 * @covers FBoxSphereBounds.transform-by
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveTransformByNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	FBoxSphereBounds Transformed = Bounds.TransformBy(FTransform::Identity);
	return Transformed.Origin.X == 0.0 && Transformed.SphereRadius == 2.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: + returns a new bounds.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: + returns a new bounds.
 * @covers FBoxSphereBounds.assignment
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FBoxSphereBounds Left(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Right(FVector(2, 0, 0), FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Original = Left;
	FBoxSphereBounds Combined = Left + Right;
	FString Text = f"{Combined}";
	return Combined.SphereRadius >= Original.SphereRadius && Left.Origin.X == 0.0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin spheres-intersect
 * @summary Boundary/ownership: Static tests do not mutate either bounds.
 * @topic Unreal
 */
/**
 * @function ObserveSpheresIntersectNominal
 * @summary Boundary/ownership: Static tests do not mutate either bounds.
 * @covers FBoxSphereBounds.spheres-intersect
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSpheresIntersectNominal()
{
	FBoxSphereBounds A(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds B(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Far(FVector(10, 0, 0), FVector(1, 1, 1), 1.0);
	return FBoxSphereBounds::SpheresIntersect(A, B) && !FBoxSphereBounds::SpheresIntersect(A, Far, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin boxes-intersect
 * @summary Boundary/ownership: Static tests do not mutate either bounds.
 * @topic Unreal
 */
/**
 * @function ObserveBoxesIntersectNominal
 * @summary Boundary/ownership: Static tests do not mutate either bounds.
 * @covers FBoxSphereBounds.boxes-intersect
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveBoxesIntersectNominal()
{
	FBoxSphereBounds A(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds B(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Far(FVector(10, 0, 0), FVector(1, 1, 1), 1.0);
	return FBoxSphereBounds::BoxesIntersect(A, B) && !FBoxSphereBounds::BoxesIntersect(A, Far);
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
 * @covers FBoxSphereBounds.equality
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Identical (0, extent 1, radius 1) bounds, a different origin, and
// Zero origin with zero radius.
// Expected observations: Identical copies compare true. Different origin
// compares false. Equality does not mutate operands.
// Boundary/ownership: Comparison is exact on all stored fields.
bool ObserveEqualityNominal()
{
	FBoxSphereBounds Left(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Right(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds Different(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
	return Left == Right && !(Left == Different);
}
/** @end */
/**
 * @begin get-box
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoxNominal
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @covers FBoxSphereBounds.get-box
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoxNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	FBox Box = Bounds.GetBox();
	return Box.Min.X == -1.0 && Box.Max.X == 1.0;
}
/** @end */
/**
 * @begin get-box-extrema
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoxExtremaNominal
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @covers FBoxSphereBounds.get-box-extrema
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoxExtremaNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	FVector MinCorner = Bounds.GetBoxExtrema(0);
	FVector MaxCorner = Bounds.GetBoxExtrema(1);
	return MinCorner.X == -1.0 && MaxCorner.X == 1.0;
}
/** @end */
/**
 * @begin get-sphere
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetSphereNominal
 * @summary Boundary/ownership: GetBox/GetSphere return value copies.
 * @covers FBoxSphereBounds.get-sphere
 * @inputs FBoxSphereBounds values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSphereNominal()
{
	FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
	FSphere Sphere = Bounds.GetSphere();
	return Sphere.W == 2.0;
}
/** @end */
