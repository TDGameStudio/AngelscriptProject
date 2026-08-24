// Purpose: Observe FCollisionShape kind tests, nearly-zero, and dimension
// getters for line/box/sphere/capsule.
// AS-facing API: bool Shape.IsLine() const; bool Shape.IsBox() const;
// bool Shape.IsCapsule() const; bool Shape.IsSphere() const;
// bool Shape.IsNearlyZero() const; FVector Shape.GetExtent() const;
// float32 Shape.GetCapsuleAxisHalfLength() const; FVector Shape.GetBox() const;
// float32 Shape.GetSphereRadius() const; float32 Shape.GetCapsuleRadius() const;
// Inputs: Default line, box half-extent (1,2,3), sphere radius 4, capsule
// radius 10 half-height 20.
// Expected observations: Default IsLine true and IsNearlyZero true. Box
// IsBox true and GetBox is (1,2,3). Sphere GetSphereRadius is 4. Capsule
// GetCapsuleRadius is 10 and GetCapsuleAxisHalfLength is 10.
// Boundary/ownership: Getters return copies of dimensions. Kind tests are
// mutually exclusive for a single shape.

namespace TS_FCollisionShape_Queries_01
{
	bool Observe_IsLine_Nominal()
	{
		FCollisionShape Shape;
		bool bDefaultIsLine = Shape.IsLine();
		Shape.SetBox(FVector(1.0, 2.0, 3.0));
		bool bBoxIsLine = Shape.IsLine();
		return bDefaultIsLine && !bBoxIsLine;
	}

	bool Observe_IsBox_Nominal()
	{
		FCollisionShape Shape;
		bool bDefaultIsBox = Shape.IsBox();
		Shape.SetBox(FVector(1.0, 2.0, 3.0));
		bool bBoxIsBox = Shape.IsBox();
		return !bDefaultIsBox && bBoxIsBox;
	}

	bool Observe_IsCapsule_Nominal()
	{
		FCollisionShape Shape;
		bool bDefaultIsCapsule = Shape.IsCapsule();
		Shape.SetCapsule(10.0, 20.0);
		bool bCapsuleIsCapsule = Shape.IsCapsule();
		return !bDefaultIsCapsule && bCapsuleIsCapsule;
	}

	bool Observe_IsSphere_Nominal()
	{
		FCollisionShape Shape;
		bool bDefaultIsSphere = Shape.IsSphere();
		Shape.SetSphere(4.0);
		bool bSphereIsSphere = Shape.IsSphere();
		return !bDefaultIsSphere && bSphereIsSphere;
	}

	bool Observe_IsNearlyZero_Nominal()
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

	bool Observe_GetExtent_Nominal()
	{
		FCollisionShape Line;
		FVector LineExtent = Line.GetExtent();
		FCollisionShape Box;
		Box.SetBox(FVector(1.0, 2.0, 3.0));
		FVector BoxExtent = Box.GetExtent();
		return LineExtent.Equals(FVector::ZeroVector) && BoxExtent.X == 1.0 && BoxExtent.Y == 2.0 && BoxExtent.Z == 3.0;
	}

	bool Observe_GetCapsuleAxisHalfLength_Nominal()
	{
		FCollisionShape Capsule;
		Capsule.SetCapsule(10.0, 20.0);
		float32 Axis = Capsule.GetCapsuleAxisHalfLength();
		return Axis == 10.0;
	}

	bool Observe_GetBox_Nominal()
	{
		FCollisionShape Box;
		Box.SetBox(FVector(1.0, 2.0, 3.0));
		FVector HalfExtent = Box.GetBox();
		return HalfExtent.X == 1.0 && HalfExtent.Y == 2.0 && HalfExtent.Z == 3.0;
	}

	bool Observe_GetSphereRadius_Nominal()
	{
		FCollisionShape Sphere;
		Sphere.SetSphere(4.0);
		float32 Radius = Sphere.GetSphereRadius();
		FCollisionShape Line;
		float32 LineRadius = Line.GetSphereRadius();
		return Radius == 4.0 && LineRadius == 0.0;
	}

	bool Observe_GetCapsuleRadius_Nominal()
	{
		FCollisionShape Capsule;
		Capsule.SetCapsule(10.0, 20.0);
		float32 Radius = Capsule.GetCapsuleRadius();
		FCollisionShape Line;
		float32 LineRadius = Line.GetCapsuleRadius();
		return Radius == 10.0 && LineRadius == 0.0;
	}
}
