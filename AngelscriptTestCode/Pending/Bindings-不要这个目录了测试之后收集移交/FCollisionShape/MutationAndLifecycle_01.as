/**
 * @version v1
 * @summary Observe SetBox, SetSphere, and both SetCapsule overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe SetBox, SetSphere, and both SetCapsule overloads.
 * @topic Baseline
 */
// void Shape.SetSphere(const float32 Radius);
// void Shape.SetCapsule(const float32 Radius, const float32 HalfHeight);
// void Shape.SetCapsule(const FVector3f& Extent);
// Inputs: HalfExtent (1,2,3), Radius 4, capsule (10,20), FVector3f(10,0,20)
// where X is radius and Z is half height, and a copied original line.
// Expected observations: SetBox makes IsBox true and GetBox (1,2,3). SetSphere
// makes GetSphereRadius 4. SetCapsule(10,20) makes radius 10 and half height
// 20. FVector3f extent sets the same capsule dimensions.
// Boundary/ownership: Set* mutate the receiver. HalfExtent is positive
// half-size in Unreal units. Capsule half height includes the hemispherical
// cap.

namespace TS_FCollisionShape_MutationAndLifecycle_01
{
	bool Observe_SetBox_Nominal()
	{
		FCollisionShape Shape;
		FCollisionShape Original = Shape;
		Shape.SetBox(FVector(1.0, 2.0, 3.0));
		FVector HalfExtent = Shape.GetBox();
		return Shape.IsBox() && HalfExtent.X == 1.0 && HalfExtent.Y == 2.0 && HalfExtent.Z == 3.0 && Original.IsLine();
	}

	bool Observe_SetSphere_Nominal()
	{
		FCollisionShape Shape;
		Shape.SetSphere(4.0);
		float32 Radius = Shape.GetSphereRadius();
		Shape.SetSphere(0.0);
		float32 ZeroRadius = Shape.GetSphereRadius();
		return Shape.IsSphere() && Radius == 4.0 && ZeroRadius == 0.0;
	}

	bool Observe_SetCapsule_Nominal()
	{
		FCollisionShape FromScalars;
		FromScalars.SetCapsule(10.0, 20.0);
		FCollisionShape FromExtent;
		FVector3f Extent(10.0, 0.0, 20.0);
		FromExtent.SetCapsule(Extent);
		return FromScalars.IsCapsule() && FromScalars.GetCapsuleRadius() == 10.0 && FromScalars.GetCapsuleHalfHeight() == 20.0 && FromExtent.IsCapsule() && FromExtent.GetCapsuleRadius() == 10.0 && FromExtent.GetCapsuleHalfHeight() == 20.0;
	}
}
/** @end */
