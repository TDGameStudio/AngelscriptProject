// Purpose: Observe FTransform3f scale removal and translation/rotation/scale
// setters.
// AS-facing API: RemoveScaling; SetToRelativeTransform; SetLocation;
// SetTranslation; AddToTranslation; SetRotation; SetScale3D;
// SetTranslationAndScale3D.
// Inputs: Scale (2,2,2), child 13 vs parent 10, location (1,2,3), add (1,0,0),
// yaw-90 quat, default __SMALL_NUMBER_flt, and a repeated SetLocation.
// Expected observations: RemoveScaling restores unit scale. Relative rewrite
// yields X=3. SetLocation/SetTranslation write GetLocation. AddToTranslation
// adds. SetRotation yields yaw 90. SetScale3D stores (2,3,4). Combined setter
// keeps rotation.
// Boundary/ownership: All listed methods mutate the receiver. RemoveScaling
// default tolerance is __SMALL_NUMBER_flt.

namespace TS_FTransform3f_MutationAndLifecycle_01
{
	bool Observe_RemoveScaling_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
		Scaled.RemoveScaling();
		FTransform3f Explicit(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(3.0, 3.0, 3.0));
		Explicit.RemoveScaling(__SMALL_NUMBER_flt);
		return Scaled.GetScale3D().Equals(FVector3f::OneVector) &&
			Explicit.GetScale3D().Equals(FVector3f::OneVector) &&
			Scaled.GetTranslation().X == 1.0;
	}

	bool Observe_SetToRelativeTransform_Nominal()
	{
		FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
		FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
		Child.SetToRelativeTransform(Parent);
		return Child.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0));
	}

	bool Observe_SetLocation_Nominal()
	{
		FTransform3f Transform = FTransform3f::Identity;
		Transform.SetLocation(FVector3f(1.0, 2.0, 3.0));
		Transform.SetLocation(FVector3f(4.0, 5.0, 6.0));
		return Transform.GetLocation().Equals(FVector3f(4.0, 5.0, 6.0));
	}

	bool Observe_SetTranslation_Nominal()
	{
		FTransform3f Transform = FTransform3f::Identity;
		Transform.SetTranslation(FVector3f(1.0, 2.0, 3.0));
		return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0));
	}

	bool Observe_AddToTranslation_Nominal()
	{
		FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
		Transform.AddToTranslation(FVector3f(1.0, 0.0, 0.0));
		Transform.AddToTranslation(FVector3f::ZeroVector);
		return Transform.GetTranslation().Equals(FVector3f(2.0, 2.0, 3.0));
	}

	bool Observe_SetRotation_Nominal()
	{
		FTransform3f Transform = FTransform3f::Identity;
		Transform.SetRotation(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
		return Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}

	bool Observe_SetScale3D_Nominal()
	{
		FTransform3f Transform = FTransform3f::Identity;
		Transform.SetScale3D(FVector3f(2.0, 3.0, 4.0));
		return Transform.GetScale3D().Equals(FVector3f(2.0, 3.0, 4.0));
	}

	bool Observe_SetTranslationAndScale3D_Nominal()
	{
		FTransform3f Transform(FRotator3f(0.0, 90.0, 0.0));
		Transform.SetTranslationAndScale3D(FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
			Transform.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
			Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}
}
