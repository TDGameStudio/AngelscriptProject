// Purpose: Observe default FCollisionShape construction and the ShapeType
// field.
// AS-facing API: FCollisionShape Shape(); ECollisionShape Shape.ShapeType;
// Inputs: Default construct, then SetBox / SetSphere / SetCapsule mutations
// of ShapeType.
// Expected observations: Default Shape() is Line. ShapeType follows SetBox
// to Box, SetSphere to Sphere, and SetCapsule to Capsule.
// Boundary/ownership: Default construction is an empty line. ShapeType is
// the current primitive kind on this value.

namespace TS_FCollisionShape_Behavior_01
{
	// FCollisionShape default construct and copy. Oracle: both are Line. Value type, no fixture.
	bool Observe_Shape_Nominal()
	{
		FCollisionShape Shape;
		FCollisionShape Copied = Shape;
		return Shape.IsLine() && Shape.ShapeType == ECollisionShape::Line && Copied.IsLine();
	}

	// FCollisionShape.ShapeType after SetBox / SetSphere / SetCapsule.
	// Inputs: (1,1,1) box, radius 4, capsule 10/20. Oracle: Line, Box, Sphere, Capsule.
	bool Observe_Surface003_Nominal()
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
}
