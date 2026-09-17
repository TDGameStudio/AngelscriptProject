/**
 * @version v1
 * @summary FSphere3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FSphere3f
 *
 * sphere
 * fsphere3f-w
 * fsphere3f-center
 * intersects
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
 * @covers FSphere3f.sphere
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSphereNominal()
{
	FSphere3f DefaultSphere;
	FSphere3f FromCenter(FVector3f(1.0, 2.0, 3.0), 4.0);
	FSphere3f Copied(FromCenter);
	FSphere DoubleSphere(FVector(0.0, 0.0, 0.0), 2.0);
	FSphere3f FromDouble(DoubleSphere);
	TArray<FVector3f> Points;
	Points.Add(FVector3f::ZeroVector);
	Points.Add(FVector3f(2.0, 0.0, 0.0));
	FSphere3f FromPoints(Points);
	FromCenter.W = 0.0;
	return DefaultSphere.W == 0.0 && DefaultSphere.Center.Equals(FVector3f::ZeroVector) && Copied.W == 4.0 && Copied.Center.X == 1.0 && FromDouble.W == 2.0 && FromPoints.W > 0.0;
}
/** @end */
/**
 * @begin fsphere3f-w
 * @summary FSphere3f.W.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FSphere3f.W.
 * @covers FSphere3f.fsphere3f-w
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
 Input center (1,2,3) radius 4. W is 4. Field read; radius is W.
bool ObserveSurface006Nominal()
{
	FSphere3f Sphere(FVector3f(1.0, 2.0, 3.0), 4.0);
	return Sphere.W == 4.0;
}
/** @end */
/**
 * @begin fsphere3f-center
 * @summary FSphere3f.Center.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FSphere3f.Center.
 * @covers FSphere3f.fsphere3f-center
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
 Input center (1,2,3) radius 4. Center is (1,2,3).
// Field read; no mutation.
bool ObserveSurface007Nominal()
{
	FSphere3f Sphere(FVector3f(1.0, 2.0, 3.0), 4.0);
	return Sphere.Center.X == 1.0 && Sphere.Center.Y == 2.0 && Sphere.Center.Z == 3.0;
}
/** @end */
/**
 * @begin intersects
 * @summary Query.
 * @topic Unreal
 */
/**
 * @function ObserveIntersectsNominal
 * @summary Query.
 * @covers FSphere3f.intersects
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIntersectsNominal()
{
	FSphere3f Sphere(FVector3f::ZeroVector, 2.0);
	FSphere3f Overlap(FVector3f(3.0, 0.0, 0.0), 2.0);
	FSphere3f Disjoint(FVector3f(10.0, 0.0, 0.0), 1.0);
	return Sphere.Intersects(Overlap) && Sphere.Intersects(Overlap, KINDA_SMALL_NUMBER) && !Sphere.Intersects(Disjoint);
}
/** @end */
/**
 * @begin assignment
 * @summary operand only.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary operand only.
 * @covers FSphere3f.assignment
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FSphere3f Left(FVector3f::ZeroVector, 1.0);
	FSphere3f Right(FVector3f(10.0, 0.0, 0.0), 1.0);
	FSphere3f Original = Left;
	FSphere3f Combined = Left + Right;
	return Combined.W > Left.W && Combined.W > Right.W && Original.W == 1.0 && Left.W == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary operand only.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary operand only.
 * @covers FSphere3f.add-assign
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FSphere3f Sphere(FVector3f::ZeroVector, 1.0);
	FSphere3f Other(FVector3f(10.0, 0.0, 0.0), 1.0);
	Sphere += Other;
	FSphere3f Nested(FVector3f::ZeroVector, 0.5);
	FSphere3f Host(FVector3f::ZeroVector, 2.0);
	float32 HostRadius = Host.W;
	Host += Nested;
	return Sphere.W > 1.0 && Host.W >= HostRadius && Other.W == 1.0;
}
/** @end */
/**
 * @begin equals
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @covers FSphere3f.equals
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FSphere3f Left(FVector3f::ZeroVector, 2.0);
	FSphere3f Right(FVector3f::ZeroVector, 2.0);
	FSphere3f Different(FVector3f::ZeroVector, 3.0);
	return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
}
/** @end */
/**
 * @begin is-inside
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @topic Unreal
 */
/**
 * @function ObserveIsInsideNominal
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @covers FSphere3f.is-inside
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsInsideNominal()
{
	FSphere3f Inner(FVector3f::ZeroVector, 2.0);
	FSphere3f Outer(FVector3f::ZeroVector, 3.0);
	return Inner.IsInside(Outer) && !Outer.IsInside(Inner) && Inner.IsInside(Outer, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin get-volume
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @topic Unreal
 */
/**
 * @function ObserveGetVolumeNominal
 * @summary Point-in-sphere IsInside is not published on FSphere3f.
 * @covers FSphere3f.get-volume
 * @inputs FSphere3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetVolumeNominal()
{
	FSphere3f Unit(FVector3f::ZeroVector, 1.0);
	FSphere3f Zero;
	float32 UnitVolume = Unit.GetVolume();
	float32 ZeroVolume = Zero.GetVolume();
	return UnitVolume > 4.0 && UnitVolume < 5.0 && ZeroVolume == 0.0;
}
/** @end */
