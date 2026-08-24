// Purpose: Observe relative location/rotation, component velocity, and sphere
// radius mutation, including default overlap-update omission.
// Runner owns the scene and sphere fixtures.
// AS-facing API: void USceneComponent.SetRelativeLocation(FVector NewLocation);
// void USceneComponent.SetRelativeRotation(FRotator NewRotation);
// void USceneComponent.SetComponentVelocity(const FVector& Velocity);
// void USphereComponent.SetSphereRadius(float32 InSphereRadius, bool bUpdateOverlaps = true);
// Inputs: Runner-owned USceneComponent, location (10,0,0), rotator (0,90,0),
// velocity (0,0,100), runner-owned USphereComponent radius 32, and
// bUpdateOverlaps false.
// Expected observations: SetRelativeLocation is visible on GetLocation.
// SetRelativeRotation is visible on Rotator Yaw. SetComponentVelocity is
// visible on GetComponentVelocity. SetSphereRadius(32) makes extents X 32.
// Boundary/ownership: Relative values are in parent space. Velocity is world
// space UU/s. SetupOwner=Runner.

namespace TS_USceneComponent_MutationAndLifecycle_01
{
	bool Observe_SetRelativeLocation_Nominal(USceneComponent Component)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		Component.SetRelativeLocation(FVector(10.0, 0.0, 0.0));
		FVector After = Component.GetComponentTransform().GetLocation();
		Component.SetRelativeLocation(FVector::ZeroVector);
		return After.X == 10.0;
	}

	bool Observe_SetRelativeRotation_Nominal(USceneComponent Component)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		Component.SetRelativeRotation(FRotator(0.0, 90.0, 0.0));
		FRotator After = Component.GetComponentTransform().Rotator();
		Component.SetRelativeRotation(FRotator::ZeroRotator);
		return After.Equals(FRotator(0.0, 90.0, 0.0), 0.01);
	}

	bool Observe_SetComponentVelocity_Nominal(USceneComponent Component)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		FVector Velocity(0.0, 0.0, 100.0);
		Component.SetComponentVelocity(Velocity);
		FVector After = Component.GetComponentVelocity();
		Component.SetComponentVelocity(FVector::ZeroVector);
		FVector Cleared = Component.GetComponentVelocity();
		return After.Equals(Velocity) && Cleared.IsNearlyZero();
	}

	bool Observe_SetSphereRadius_Nominal(USphereComponent Sphere)
	{
		if (Sphere is null)
		{
			throw("TS_USceneComponent_MutationAndLifecycle_01 setup: required Sphere is null");
		}
		Sphere.SetSphereRadius(32.0);
		FVector ExtentsDefault = Sphere.GetBoundingBoxExtents();
		Sphere.SetSphereRadius(16.0, true);
		FVector ExtentsOverlap = Sphere.GetBoundingBoxExtents();
		Sphere.SetSphereRadius(8.0, false);
		FVector ExtentsNoOverlap = Sphere.GetBoundingBoxExtents();
		return ExtentsDefault.X == 32.0 && ExtentsOverlap.X == 16.0 && ExtentsNoOverlap.X == 8.0;
	}
}
