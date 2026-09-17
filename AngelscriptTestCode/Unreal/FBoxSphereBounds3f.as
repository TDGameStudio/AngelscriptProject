/**
 * @version v1
 * @summary FBoxSphereBounds3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBoxSphereBounds3f
 *
 * bounds
 * surface-008
 * fboxspherebounds3f-boxextent-origin
 * fboxspherebounds3f-sphereradius-origin-0
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
 * @summary FBoxSphereBounds3f from parts, FBoxSphereBounds, box, sphere, and points.
 * @topic Unreal
 */
/**
 * @function ObserveBoundsNominal
 * @summary FBoxSphereBounds3f from parts, FBoxSphereBounds, box, sphere, and points.
 * @covers FBoxSphereBounds3f.bounds
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveBoundsNominal()
{
	FBoxSphereBounds3f DefaultBounds;
	FBoxSphereBounds3f FromParts(FVector3f(1, 1, 1), FVector3f(1, 1, 1), 2.0);
	FBoxSphereBounds DoubleBounds(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
	FBoxSphereBounds3f FromDouble(DoubleBounds);
	FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
	FSphere3f Sphere(FVector3f(1, 1, 1), 2.0);
	FBoxSphereBounds3f FromBoxSphere(Box, Sphere);
	FBoxSphereBounds3f FromBox(Box);
	FBoxSphereBounds3f FromSphere(Sphere);
	TArray<FVector3f> Points;
	Points.Add(FVector3f::ZeroVector);
	Points.Add(FVector3f(2, 2, 2));
	FBoxSphereBounds3f FromPoints(Points);
	return FromParts.Origin.X == 1.0 && FromParts.SphereRadius == 2.0 && FromDouble.SphereRadius > 0.0 && FromPoints.BoxExtent.X > 0.0 && FromBoxSphere.SphereRadius > 0.0 && FromBox.SphereRadius > 0.0 && FromSphere.SphereRadius > 0.0 && DefaultBounds.SphereRadius == 0.0;
}
/** @end */
/**
 * @begin surface-008
 * @summary FBoxSphereBounds3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FBoxSphereBounds3f.
 * @covers FBoxSphereBounds3f.surface-008
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
Origin on (1,0,0) extent 1 radius 2. Oracle: Origin.X==1. Field read does not mutate.
bool ObserveSurface008Nominal()
{
	FBoxSphereBounds3f Bounds(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 2.0);
	return Bounds.Origin.X == 1.0;
}
/** @end */
/**
 * @begin fboxspherebounds3f-boxextent-origin
 * @summary FBoxSphereBounds3f.BoxExtent on origin
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FBoxSphereBounds3f.BoxExtent on origin
 * @covers FBoxSphereBounds3f.fboxspherebounds3f-boxextent-origin
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
 0 extent (2,1,1). Oracle: BoxExtent.X==2. Field read does not mutate.
bool ObserveSurface009Nominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(2, 1, 1), 2.0);
	return Bounds.BoxExtent.X == 2.0;
}
/** @end */
/**
 * @begin fboxspherebounds3f-sphereradius-origin-0
 * @summary FBoxSphereBounds3f.SphereRadius on origin 0 radius 3.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FBoxSphereBounds3f.SphereRadius on origin 0 radius 3.
 * @covers FBoxSphereBounds3f.fboxspherebounds3f-sphereradius-origin-0
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 3.0);
	return Bounds.SphereRadius == 3.0;
}
/** @end */
/**
 * @begin compute-squared-distance-from-box-to-point
 * @summary Boundary/ownership: Helpers return new values.
 * @topic Unreal
 */
/**
 * @function ObserveComputeSquaredDistanceFromBoxToPointNominal
 * @summary Boundary/ownership: Helpers return new values.
 * @covers FBoxSphereBounds3f.compute-squared-distance-from-box-to-point
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComputeSquaredDistanceFromBoxToPointNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	float32 Interior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector3f::ZeroVector);
	float32 Exterior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector3f(5, 0, 0));
	return Interior == 0.0 && Exterior > 0.0;
}
/** @end */
/**
 * @begin expand-by
 * @summary Boundary/ownership: Helpers return new values.
 * @topic Unreal
 */
/**
 * @function ObserveExpandByNominal
 * @summary Boundary/ownership: Helpers return new values.
 * @covers FBoxSphereBounds3f.expand-by
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpandByNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	FBoxSphereBounds3f Expanded = Bounds.ExpandBy(1.0);
	return Expanded.SphereRadius > Bounds.SphereRadius;
}
/** @end */
/**
 * @begin transform-by
 * @summary Boundary/ownership: Helpers return new values.
 * @topic Unreal
 */
/**
 * @function ObserveTransformByNominal
 * @summary Boundary/ownership: Helpers return new values.
 * @covers FBoxSphereBounds3f.transform-by
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveTransformByNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	FBoxSphereBounds3f Transformed = Bounds.TransformBy(FTransform3f::Identity);
	return Transformed.Origin.X == 0.0 && Transformed.SphereRadius == 2.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: + returns a new single-precision bounds.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: + returns a new single-precision bounds.
 * @covers FBoxSphereBounds3f.assignment
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FBoxSphereBounds3f Left(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Right(FVector3f(2, 0, 0), FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Original = Left;
	FBoxSphereBounds3f Combined = Left + Right;
	FString Text = f"{Combined}";
	return Combined.SphereRadius >= Original.SphereRadius && Left.Origin.X == 0.0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin spheres-intersect
 * @summary Boundary/ownership: Static tests do not mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveSpheresIntersectNominal
 * @summary Boundary/ownership: Static tests do not mutate either operand.
 * @covers FBoxSphereBounds3f.spheres-intersect
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSpheresIntersectNominal()
{
	FBoxSphereBounds3f A(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f B(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Far(FVector3f(10, 0, 0), FVector3f(1, 1, 1), 1.0);
	return FBoxSphereBounds3f::SpheresIntersect(A, B) && !FBoxSphereBounds3f::SpheresIntersect(A, Far, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin boxes-intersect
 * @summary Boundary/ownership: Static tests do not mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveBoxesIntersectNominal
 * @summary Boundary/ownership: Static tests do not mutate either operand.
 * @covers FBoxSphereBounds3f.boxes-intersect
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveBoxesIntersectNominal()
{
	FBoxSphereBounds3f A(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f B(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Far(FVector3f(10, 0, 0), FVector3f(1, 1, 1), 1.0);
	return FBoxSphereBounds3f::BoxesIntersect(A, B) && !FBoxSphereBounds3f::BoxesIntersect(A, Far);
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: Equality is exact on stored float32 fields.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: Equality is exact on stored float32 fields.
 * @covers FBoxSphereBounds3f.equality
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FBoxSphereBounds3f Left(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Right(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
	FBoxSphereBounds3f Different(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
	return (Left == Right) && !(Left == Different);
}
/** @end */
/**
 * @begin get-box
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoxNominal
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @covers FBoxSphereBounds3f.get-box
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoxNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	FBox3f Box = Bounds.GetBox();
	return Box.Min.X == -1.0 && Box.Max.X == 1.0;
}
/** @end */
/**
 * @begin get-box-extrema
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoxExtremaNominal
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @covers FBoxSphereBounds3f.get-box-extrema
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoxExtremaNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	FVector3f MinCorner = Bounds.GetBoxExtrema(0);
	FVector3f MaxCorner = Bounds.GetBoxExtrema(1);
	return MinCorner.X == -1.0 && MaxCorner.X == 1.0;
}
/** @end */
/**
 * @begin get-sphere
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @topic Unreal
 */
/**
 * @function ObserveGetSphereNominal
 * @summary Boundary/ownership: Returned FBox3f/FSphere3f are value copies.
 * @covers FBoxSphereBounds3f.get-sphere
 * @inputs FBoxSphereBounds3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSphereNominal()
{
	FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
	FSphere3f Sphere = Bounds.GetSphere();
	return Sphere.W == 2.0;
}
/** @end */
