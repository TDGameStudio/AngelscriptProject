/**
 * @version v1
 * @summary Observe FTransform scale removal and translation/rotation/scale setters.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform scale removal and translation/rotation/scale setters.
 * @topic Baseline
 */
// SetTranslation; AddToTranslation; SetRotation; SetScale3D;
// SetTranslationAndScale3D.
// Inputs: Scale (2,2,2), child 13 vs parent 10, location (1,2,3), add (1,0,0),
// yaw-90 quat, default SMALL_NUMBER, and a repeated SetLocation.
// Expected observations: RemoveScaling restores unit scale. Relative rewrite
// yields X=3. SetLocation/SetTranslation write GetLocation. AddToTranslation
// adds. SetRotation yields yaw 90. SetScale3D stores (2,3,4). Combined setter
// keeps rotation.
// Boundary/ownership: All listed methods mutate the receiver. RemoveScaling
// default tolerance is SMALL_NUMBER.

namespace TS_FTransform_MutationAndLifecycle_01
{
	bool Observe_RemoveScaling_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector(1.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		Scaled.RemoveScaling();
		FTransform Explicit(FQuat::Identity, FVector::ZeroVector, FVector(3.0, 3.0, 3.0));
		Explicit.RemoveScaling(SMALL_NUMBER);
		return Scaled.GetScale3D().Equals(FVector::OneVector) &&
			Explicit.GetScale3D().Equals(FVector::OneVector) &&
			Scaled.GetTranslation().X == 1.0;
	}

	bool Observe_SetToRelativeTransform_Nominal()
	{
		FTransform Child(FVector(13.0, 0.0, 0.0));
		FTransform Parent(FVector(10.0, 0.0, 0.0));
		Child.SetToRelativeTransform(Parent);
		return Child.GetTranslation().Equals(FVector(3.0, 0.0, 0.0));
	}

	bool Observe_SetLocation_Nominal()
	{
		FTransform Transform = FTransform::Identity;
		Transform.SetLocation(FVector(1.0, 2.0, 3.0));
		Transform.SetLocation(FVector(4.0, 5.0, 6.0));
		return Transform.GetLocation().Equals(FVector(4.0, 5.0, 6.0));
	}

	bool Observe_SetTranslation_Nominal()
	{
		FTransform Transform = FTransform::Identity;
		Transform.SetTranslation(FVector(1.0, 2.0, 3.0));
		return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0));
	}

	bool Observe_AddToTranslation_Nominal()
	{
		FTransform Transform(FVector(1.0, 2.0, 3.0));
		Transform.AddToTranslation(FVector(1.0, 0.0, 0.0));
		Transform.AddToTranslation(FVector::ZeroVector);
		return Transform.GetTranslation().Equals(FVector(2.0, 2.0, 3.0));
	}

	bool Observe_SetRotation_Nominal()
	{
		FTransform Transform = FTransform::Identity;
		Transform.SetRotation(FQuat(FRotator(0.0, 90.0, 0.0)));
		return Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}

	bool Observe_SetScale3D_Nominal()
	{
		FTransform Transform = FTransform::Identity;
		Transform.SetScale3D(FVector(2.0, 3.0, 4.0));
		return Transform.GetScale3D().Equals(FVector(2.0, 3.0, 4.0));
	}

	bool Observe_SetTranslationAndScale3D_Nominal()
	{
		FTransform Transform(FRotator(0.0, 90.0, 0.0));
		Transform.SetTranslationAndScale3D(FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
			Transform.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
			Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}
}
/** @end */
