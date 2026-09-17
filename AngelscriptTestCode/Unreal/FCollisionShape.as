/**
 * @version v1
 * @summary FCollisionShape host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FCollisionShape
 *
 * shape
 * inputs-1-1-1
 * oracle-copy-equals-line
 * set-box
 * set-sphere
 * set-capsule
 * make-box
 * make-sphere
 * make-capsule
 * is-line
 * is-box
 * is-capsule
 * is-sphere
 * is-nearly-zero
 * get-extent
 * get-capsule-axis-half-length
 * get-box
 * get-sphere-radius
 * get-capsule-radius
 * get-capsule-half-height
 * min-box-extent
 * min-sphere-radius
 * min-capsule-radius
 * min-capsule-axis-half-height
 */
/**
 * @begin shape
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveShapeNominal
 * @summary Expected observations:
 * @covers FCollisionShape.shape
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default Shape() is Line. ShapeType follows SetBox
// to Box, SetSphere to Sphere, and SetCapsule to Capsule.
// Boundary/ownership: Default construction is an empty line. ShapeType is
// the current primitive kind on this value.
// FCollisionShape default construct and copy. Oracle: both are Line. Value type, no fixture.
bool ObserveShapeNominal()
{
	FCollisionShape Shape;
	FCollisionShape Copied = Shape;
	return Shape.IsLine() && Shape.ShapeType == ECollisionShape::Line && Copied.IsLine();
}
/** @end */
/**
 * @begin inputs-1-1-1
 * @summary Inputs: (1,1,1) box, radius 4, capsule 10/20.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary Inputs: (1,1,1) box, radius 4, capsule 10/20.
 * @covers FCollisionShape.inputs-1-1-1
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSurface003Nominal()
{
	FCollisionShape Shape;
	ECollisionShape DefaultType = Shape.ShapeType;
	Shape.SetBox(FVector(1.0, 1.0, 1.0));
	ECollisionShape BoxType = Shape.ShapeType;
	Shape.SetSphere(4.0);
	ECollisionShape SphereType = Shape.ShapeType;
	Shape.SetCapsule(10.0, 20.0);
	ECollisionShape CapsuleType = Shape.ShapeType;
	return DefaultType == ECollisionShape::Line && BoxType == ECollisionShape::Box && SphereType == ECollisionShape::Sphere && CapsuleType == ECollisionShape::Capsule;
}
/** @end */
/**
 * @begin oracle-copy-equals-line
 * @summary Oracle: copy equals Line, assignment to Box differs, Sphere and Capsule are distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Oracle: copy equals Line, assignment to Box differs, Sphere and Capsule are distinct.
 * @covers FCollisionShape.oracle-copy-equals-line
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	ECollisionShape Line = ECollisionShape::Line;
	ECollisionShape Box = ECollisionShape::Box;
	ECollisionShape Sphere = ECollisionShape::Sphere;
	ECollisionShape Capsule = ECollisionShape::Capsule;
	ECollisionShape Copied = Line;
	bool bCopyEqualsLine = Copied == Line;
	Copied = Box;
	return bCopyEqualsLine && Copied == Box && Line != Box && Sphere != Box && Capsule != Sphere && Capsule != Line;
}
/** @end */
/**
 * @begin set-box
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSetBoxNominal
 * @summary Observe the container API.
 * @covers FCollisionShape.set-box
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: HalfExtent (1,2,3), Radius 4, capsule (10,20), FVector3f(10,0,20)
// where X is radius and Z is half height, and a copied original line.
// Expected observations: SetBox makes IsBox true and GetBox (1,2,3). SetSphere
// makes GetSphereRadius 4. SetCapsule(10,20) makes radius 10 and half height
// 20. FVector3f extent sets the same capsule dimensions.
// Boundary/ownership: Set* mutate the receiver. HalfExtent is positive
// half-size in Unreal units. Capsule half height includes the hemispherical
// cap.
bool ObserveSetBoxNominal()
{
	FCollisionShape Shape;
	FCollisionShape Original = Shape;
	Shape.SetBox(FVector(1.0, 2.0, 3.0));
	FVector HalfExtent = Shape.GetBox();
	return Shape.IsBox() && HalfExtent.X == 1.0 && HalfExtent.Y == 2.0 && HalfExtent.Z == 3.0 && Original.IsLine();
}
/** @end */
/**
 * @begin set-sphere
 * @summary cap.
 * @topic Unreal
 */
/**
 * @function ObserveSetSphereNominal
 * @summary cap.
 * @covers FCollisionShape.set-sphere
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetSphereNominal()
{
	FCollisionShape Shape;
	Shape.SetSphere(4.0);
	float32 Radius = Shape.GetSphereRadius();
	Shape.SetSphere(0.0);
	float32 ZeroRadius = Shape.GetSphereRadius();
	return Shape.IsSphere() && Radius == 4.0 && ZeroRadius == 0.0;
}
/** @end */
/**
 * @begin set-capsule
 * @summary cap.
 * @topic Unreal
 */
/**
 * @function ObserveSetCapsuleNominal
 * @summary cap.
 * @covers FCollisionShape.set-capsule
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetCapsuleNominal()
{
	FCollisionShape FromScalars;
	FromScalars.SetCapsule(10.0, 20.0);
	FCollisionShape FromExtent;
	FVector3f Extent(10.0, 0.0, 20.0);
	FromExtent.SetCapsule(Extent);
	return FromScalars.IsCapsule() && FromScalars.GetCapsuleRadius() == 10.0 && FromScalars.GetCapsuleHalfHeight() == 20.0 && FromExtent.IsCapsule() && FromExtent.GetCapsuleRadius() == 10.0 && FromExtent.GetCapsuleHalfHeight() == 20.0;
}
/** @end */
/**
 * @begin make-box
 * @summary capsule (10,20),
 * @topic Unreal
 */
/**
 * @function ObserveMakeBoxNominal
 * @summary capsule (10,20),
 * @covers FCollisionShape.make-box
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// capsule (10,20),

 and Extent (10,0,20) where X is radius and Z is half height.
// Expected observations: MakeBox returns IsBox with GetBox (1,2,3). MakeSphere
// returns radius 4. Both MakeCapsule overloads return radius 10 and half
// height 20.
// Boundary/ownership: Factories return a new shape. They do not mutate a
// receiver.
bool ObserveMakeBoxNominal()
{
	FCollisionShape FromVector = FCollisionShape::MakeBox(FVector(1.0, 2.0, 3.0));
	FVector FromVectorBox = FromVector.GetBox();
	FCollisionShape FromVector3f = FCollisionShape::MakeBox(FVector3f(1.0, 2.0, 3.0));
	FVector FromVector3fBox = FromVector3f.GetBox();
	return FromVector.IsBox() && FromVectorBox.X == 1.0 && FromVectorBox.Y == 2.0 && FromVectorBox.Z == 3.0 && FromVector3f.IsBox() && FromVector3fBox.Y == 2.0 && FromVector3fBox.Z == 3.0;
}
/** @end */
/**
 * @begin make-sphere
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveMakeSphereNominal
 * @summary receiver.
 * @covers FCollisionShape.make-sphere
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// capsule (10,20),

bool ObserveMakeSphereNominal()
{
	FCollisionShape Sphere = FCollisionShape::MakeSphere(4.0);
	float32 Radius = Sphere.GetSphereRadius();
	FCollisionShape Zero = FCollisionShape::MakeSphere(0.0);
	return Sphere.IsSphere() && Radius == 4.0 && Zero.GetSphereRadius() == 0.0;
}
/** @end */
/**
 * @begin make-capsule
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveMakeCapsuleNominal
 * @summary receiver.
 * @covers FCollisionShape.make-capsule
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// capsule (10,20),

bool ObserveMakeCapsuleNominal()
{
	FCollisionShape FromScalars = FCollisionShape::MakeCapsule(10.0, 20.0);
	FCollisionShape FromExtent = FCollisionShape::MakeCapsule(FVector(10.0, 0.0, 20.0));
	return FromScalars.IsCapsule() && FromScalars.GetCapsuleRadius() == 10.0 && FromScalars.GetCapsuleHalfHeight() == 20.0 && FromExtent.IsCapsule() && FromExtent.GetCapsuleRadius() == 10.0 && FromExtent.GetCapsuleHalfHeight() == 20.0;
}
/** @end */
/**
 * @begin is-line
 * @summary IsBox true and
 * @topic Unreal
 */
/**
 * @function ObserveIsLineNominal
 * @summary IsBox true and
 * @covers FCollisionShape.is-line
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

 GetBox is (1,2,3). Sphere GetSphereRadius is 4. Capsule
// GetCapsuleRadius is 10 and GetCapsuleAxisHalfLength is 10.
// Boundary/ownership: Getters return copies of dimensions. Kind tests are
// mutually exclusive for a single shape.
bool ObserveIsLineNominal()
{
	FCollisionShape Shape;
	bool bDefaultIsLine = Shape.IsLine();
	Shape.SetBox(FVector(1.0, 2.0, 3.0));
	bool bBoxIsLine = Shape.IsLine();
	return bDefaultIsLine && !bBoxIsLine;
}
/** @end */
/**
 * @begin is-box
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveIsBoxNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.is-box
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveIsBoxNominal()
{
	FCollisionShape Shape;
	bool bDefaultIsBox = Shape.IsBox();
	Shape.SetBox(FVector(1.0, 2.0, 3.0));
	bool bBoxIsBox = Shape.IsBox();
	return !bDefaultIsBox && bBoxIsBox;
}
/** @end */
/**
 * @begin is-capsule
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveIsCapsuleNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.is-capsule
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveIsCapsuleNominal()
{
	FCollisionShape Shape;
	bool bDefaultIsCapsule = Shape.IsCapsule();
	Shape.SetCapsule(10.0, 20.0);
	bool bCapsuleIsCapsule = Shape.IsCapsule();
	return !bDefaultIsCapsule && bCapsuleIsCapsule;
}
/** @end */
/**
 * @begin is-sphere
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveIsSphereNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.is-sphere
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveIsSphereNominal()
{
	FCollisionShape Shape;
	bool bDefaultIsSphere = Shape.IsSphere();
	Shape.SetSphere(4.0);
	bool bSphereIsSphere = Shape.IsSphere();
	return !bDefaultIsSphere && bSphereIsSphere;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.is-nearly-zero
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveIsNearlyZeroNominal()
{
	FCollisionShape Line;
	bool bLineNearlyZero = Line.IsNearlyZero();
	FCollisionShape Box;
	Box.SetBox(FVector(1.0, 1.0, 1.0));
	bool bBoxNearlyZero = Box.IsNearlyZero();
	FCollisionShape Tiny;
	Tiny.SetBox(FVector(0.0, 0.0, 0.0));
	bool bTinyNearlyZero = Tiny.IsNearlyZero();
	return bLineNearlyZero && !bBoxNearlyZero && bTinyNearlyZero;
}
/** @end */
/**
 * @begin get-extent
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetExtentNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.get-extent
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveGetExtentNominal()
{
	FCollisionShape Line;
	FVector LineExtent = Line.GetExtent();
	FCollisionShape Box;
	Box.SetBox(FVector(1.0, 2.0, 3.0));
	FVector BoxExtent = Box.GetExtent();
	return LineExtent.Equals(FVector::ZeroVector) && BoxExtent.X == 1.0 && BoxExtent.Y == 2.0 && BoxExtent.Z == 3.0;
}
/** @end */
/**
 * @begin get-capsule-axis-half-length
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetCapsuleAxisHalfLengthNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.get-capsule-axis-half-length
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveGetCapsuleAxisHalfLengthNominal()
{
	FCollisionShape Capsule;
	Capsule.SetCapsule(10.0, 20.0);
	float32 Axis = Capsule.GetCapsuleAxisHalfLength();
	return Axis == 10.0;
}
/** @end */
/**
 * @begin get-box
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoxNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.get-box
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveGetBoxNominal()
{
	FCollisionShape Box;
	Box.SetBox(FVector(1.0, 2.0, 3.0));
	FVector HalfExtent = Box.GetBox();
	return HalfExtent.X == 1.0 && HalfExtent.Y == 2.0 && HalfExtent.Z == 3.0;
}
/** @end */
/**
 * @begin get-sphere-radius
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetSphereRadiusNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.get-sphere-radius
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveGetSphereRadiusNominal()
{
	FCollisionShape Sphere;
	Sphere.SetSphere(4.0);
	float32 Radius = Sphere.GetSphereRadius();
	FCollisionShape Line;
	float32 LineRadius = Line.GetSphereRadius();
	return Radius == 4.0 && LineRadius == 0.0;
}
/** @end */
/**
 * @begin get-capsule-radius
 * @summary mutually exclusive for a single shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetCapsuleRadiusNominal
 * @summary mutually exclusive for a single shape.
 * @covers FCollisionShape.get-capsule-radius
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
// IsBox true and

bool ObserveGetCapsuleRadiusNominal()
{
	FCollisionShape Capsule;
	Capsule.SetCapsule(10.0, 20.0);
	float32 Radius = Capsule.GetCapsuleRadius();
	FCollisionShape Line;
	float32 LineRadius = Line.GetCapsuleRadius();
	return Radius == 10.0 && LineRadius == 0.0;
}
/** @end */
/**
 * @begin get-capsule-half-height
 * @summary mutate a shape.
 * @topic Unreal
 */
/**
 * @function ObserveGetCapsuleHalfHeightNominal
 * @summary mutate a shape.
 * @covers FCollisionShape.get-capsule-half-height
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCapsuleHalfHeightNominal()
{
	FCollisionShape Capsule;
	Capsule.SetCapsule(10.0, 20.0);
	float32 HalfHeight = Capsule.GetCapsuleHalfHeight();
	FCollisionShape Line;
	float32 LineHalfHeight = Line.GetCapsuleHalfHeight();
	return HalfHeight == 20.0 && LineHalfHeight == 0.0;
}
/** @end */
/**
 * @begin min-box-extent
 * @summary mutate a shape.
 * @topic Unreal
 */
/**
 * @function ObserveMinBoxExtentNominal
 * @summary mutate a shape.
 * @covers FCollisionShape.min-box-extent
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinBoxExtentNominal()
{
	float32 MinExtent = FCollisionShape::MinBoxExtent();
	return MinExtent > 0.0 && MinExtent == KINDA_SMALL_NUMBER;
}
/** @end */
/**
 * @begin min-sphere-radius
 * @summary mutate a shape.
 * @topic Unreal
 */
/**
 * @function ObserveMinSphereRadiusNominal
 * @summary mutate a shape.
 * @covers FCollisionShape.min-sphere-radius
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinSphereRadiusNominal()
{
	float32 MinRadius = FCollisionShape::MinSphereRadius();
	return MinRadius > 0.0 && MinRadius == KINDA_SMALL_NUMBER;
}
/** @end */
/**
 * @begin min-capsule-radius
 * @summary mutate a shape.
 * @topic Unreal
 */
/**
 * @function ObserveMinCapsuleRadiusNominal
 * @summary mutate a shape.
 * @covers FCollisionShape.min-capsule-radius
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinCapsuleRadiusNominal()
{
	float32 MinRadius = FCollisionShape::MinCapsuleRadius();
	return MinRadius > 0.0 && MinRadius == KINDA_SMALL_NUMBER;
}
/** @end */
/**
 * @begin min-capsule-axis-half-height
 * @summary mutate a shape.
 * @topic Unreal
 */
/**
 * @function ObserveMinCapsuleAxisHalfHeightNominal
 * @summary mutate a shape.
 * @covers FCollisionShape.min-capsule-axis-half-height
 * @inputs FCollisionShape values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinCapsuleAxisHalfHeightNominal()
{
	float32 MinAxis = FCollisionShape::MinCapsuleAxisHalfHeight();
	return MinAxis > 0.0 && MinAxis == KINDA_SMALL_NUMBER;
}
/** @end */
