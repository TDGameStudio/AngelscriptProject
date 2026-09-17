/**
 * @version v1
 * @summary Observe FCollisionShape::MakeBox / MakeSphere / MakeCapsule factories, including both box and capsule overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FCollisionShape::MakeBox / MakeSphere / MakeCapsule factories, including both box and capsule overloads.
 * @topic Baseline
 */
// FCollisionShape FCollisionShape::MakeBox(const FVector3f& BoxHalfExtent);
// FCollisionShape FCollisionShape::MakeSphere(const float32 SphereRadius);
// FCollisionShape FCollisionShape::MakeCapsule(const float32 CapsuleRadius, const float32 CapsuleHalfHeight);
// FCollisionShape FCollisionShape::MakeCapsule(const FVector& Extent);
// Inputs: Box half-extent (1,2,3) as FVector and FVector3f, sphere radius 4,
// capsule (10,20), and Extent (10,0,20) where X is radius and Z is half height.
// Expected observations: MakeBox returns IsBox with GetBox (1,2,3). MakeSphere
// returns radius 4. Both MakeCapsule overloads return radius 10 and half
// height 20.
// Boundary/ownership: Factories return a new shape. They do not mutate a
// receiver.

namespace TS_FCollisionShape_NamespaceAndGlobalFunctions_01
{
	bool Observe_MakeBox_Nominal()
	{
		FCollisionShape FromVector = FCollisionShape::MakeBox(FVector(1.0, 2.0, 3.0));
		FVector FromVectorBox = FromVector.GetBox();
		FCollisionShape FromVector3f = FCollisionShape::MakeBox(FVector3f(1.0, 2.0, 3.0));
		FVector FromVector3fBox = FromVector3f.GetBox();
		return FromVector.IsBox() && FromVectorBox.X == 1.0 && FromVectorBox.Y == 2.0 && FromVectorBox.Z == 3.0 && FromVector3f.IsBox() && FromVector3fBox.Y == 2.0 && FromVector3fBox.Z == 3.0;
	}

	bool Observe_MakeSphere_Nominal()
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(4.0);
		float32 Radius = Sphere.GetSphereRadius();
		FCollisionShape Zero = FCollisionShape::MakeSphere(0.0);
		return Sphere.IsSphere() && Radius == 4.0 && Zero.GetSphereRadius() == 0.0;
	}

	bool Observe_MakeCapsule_Nominal()
	{
		FCollisionShape FromScalars = FCollisionShape::MakeCapsule(10.0, 20.0);
		FCollisionShape FromExtent = FCollisionShape::MakeCapsule(FVector(10.0, 0.0, 20.0));
		return FromScalars.IsCapsule() && FromScalars.GetCapsuleRadius() == 10.0 && FromScalars.GetCapsuleHalfHeight() == 20.0 && FromExtent.IsCapsule() && FromExtent.GetCapsuleRadius() == 10.0 && FromExtent.GetCapsuleHalfHeight() == 20.0;
	}
}
/** @end */
