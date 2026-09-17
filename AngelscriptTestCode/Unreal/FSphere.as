/**
 * @version v1
 * @summary FSphere host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FSphere
 *
 * sphere
 * fsphere-w
 * fsphere-center
 * intersects
 * transform-by
 * assignment
 * add-assign
 * equals
 * is-inside
 * get-volume
 */
/**
 * @begin sphere
 * @summary Copy is independent of later source mutation.
 * @topic Unreal
 */
/**
 * @function ObserveSphereNominal
 * @summary Copy is independent of later source mutation.
 * @covers FSphere.sphere
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSphereNominal()
{
	FSphere DefaultSphere;
	FSphere FromCenter(FVector(1.0, 2.0, 3.0), 4.0);
	FSphere Copied(FromCenter);
	FSphere3f Single(FVector3f(0.0, 0.0, 0.0), 2.0);
	FSphere FromSingle(Single);
	TArray<FVector> Points;
	Points.Add(FVector::ZeroVector);
	Points.Add(FVector(2.0, 0.0, 0.0));
	FSphere FromPoints(Points);
	FromCenter.W = 0.0;
	return DefaultSphere.W == 0.0 && DefaultSphere.Center.IsNearlyZero() && Copied.W == 4.0 && Copied.Center.X == 1.0 && FromSingle.W == 2.0 && FromPoints.W > 0.0;
}
/** @end */
/**
 * @begin fsphere-w
 * @summary FSphere.W.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FSphere.W.
 * @covers FSphere.fsphere-w
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
 Input center (1,2,3) radius 4. W is 4. Field read; radius is W.
bool ObserveSurface006Nominal()
{
	FSphere Sphere(FVector(1.0, 2.0, 3.0), 4.0);
	return Sphere.W == 4.0;
}
/** @end */
/**
 * @begin fsphere-center
 * @summary FSphere.Center.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FSphere.Center.
 * @covers FSphere.fsphere-center
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
 Input center (1,2,3) radius 4. Center is (1,2,3).
// Field read; no mutation.
bool ObserveSurface007Nominal()
{
	FSphere Sphere(FVector(1.0, 2.0, 3.0), 4.0);
	return Sphere.Center.X == 1.0 && Sphere.Center.Y == 2.0 && Sphere.Center.Z == 3.0;
}
/** @end */
/**
 * @begin intersects
 * @summary KINDA_SMALL_NUMBER; disjoint is false.
 * @topic Unreal
 */
/**
 * @function ObserveIntersectsNominal
 * @summary KINDA_SMALL_NUMBER; disjoint is false.
 * @covers FSphere.intersects
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIntersectsNominal()
{
	FSphere Sphere(FVector::ZeroVector, 2.0);
	FSphere Overlap(FVector(3.0, 0.0, 0.0), 2.0);
	FSphere Disjoint(FVector(10.0, 0.0, 0.0), 1.0);
	return Sphere.Intersects(Overlap) && Sphere.Intersects(Overlap, KINDA_SMALL_NUMBER) && !Sphere.Intersects(Disjoint);
}
/** @end */
/**
 * @begin transform-by
 * @summary Returns a new sphere.
 * @topic Unreal
 */
/**
 * @function ObserveTransformByNominal
 * @summary Returns a new sphere.
 * @covers FSphere.transform-by
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveTransformByNominal()
{
	FSphere Sphere(FVector::ZeroVector, 2.0);
	FSphere Identity = Sphere.TransformBy(FTransform::Identity);
	FSphere Translated = Sphere.TransformBy(FTransform(FVector(5.0, 0.0, 0.0)));
	return Identity.Center.X == 0.0 && Identity.W == 2.0 && Translated.Center.X == 5.0 && Translated.W == 2.0 && Sphere.Center.X == 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: + returns a new enclosing sphere.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: + returns a new enclosing sphere.
 * @covers FSphere.assignment
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FSphere Left(FVector::ZeroVector, 1.0);
	FSphere Right(FVector(10.0, 0.0, 0.0), 1.0);
	FSphere Original = Left;
	FSphere Combined = Left + Right;
	return Combined.W > Left.W && Combined.W > Right.W && Original.W == 1.0 && Left.W == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Boundary/ownership: + returns a new enclosing sphere.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Boundary/ownership: + returns a new enclosing sphere.
 * @covers FSphere.add-assign
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FSphere Left(FVector::ZeroVector, 1.0);
	FSphere Right(FVector(10.0, 0.0, 0.0), 1.0);
	Left += Right;
	FSphere Nested(FVector::ZeroVector, 0.5);
	FSphere Host(FVector::ZeroVector, 2.0);
	float64 HostRadius = Host.W;
	Host += Nested;
	return Left.W > 1.0 && Host.W >= HostRadius && Right.W == 1.0;
}
/** @end */
/**
 * @begin equals
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @covers FSphere.equals
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FSphere Left(FVector::ZeroVector, 2.0);
	FSphere Right(FVector::ZeroVector, 2.0);
	FSphere Different(FVector::ZeroVector, 3.0);
	return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
}
/** @end */
/**
 * @begin is-inside
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideNominal
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @covers FSphere.is-inside
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsInsideNominal()
{
	FSphere Inner(FVector::ZeroVector, 2.0);
	FSphere Outer(FVector::ZeroVector, 3.0);
	return Inner.IsInside(Outer) && !Outer.IsInside(Inner) && Inner.IsInside(Outer, KINDA_SMALL_NUMBER) && Inner.IsInside(FVector(1.0, 0.0, 0.0)) && !Inner.IsInside(FVector(5.0, 0.0, 0.0)) && Inner.IsInside(FVector::ZeroVector, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin get-volume
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @topic Unreal
 */
/**
 * @function ObserveGetVolumeNominal
 * @summary Boundary/ownership: Queries do not mutate the sphere.
 * @covers FSphere.get-volume
 * @inputs FSphere values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetVolumeNominal()
{
	FSphere Unit(FVector::ZeroVector, 1.0);
	FSphere Zero;
	float32 UnitVolume = Unit.GetVolume();
	float32 ZeroVolume = Zero.GetVolume();
	return UnitVolume > 4.0 && UnitVolume < 5.0 && ZeroVolume == 0.0;
}
/** @end */
