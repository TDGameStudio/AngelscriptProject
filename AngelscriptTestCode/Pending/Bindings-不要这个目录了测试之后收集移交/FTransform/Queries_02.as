/**
 * @version v1
 * @summary Observe FTransform determinant, translation, scale, and rotation accessors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform determinant, translation, scale, and rotation accessors.
 * @topic Baseline
 */
// is 24. GetTranslation matches the constructor. Identity scale is OneVector.
// Identity rotation is Identity quat.
// Boundary/ownership: Accessors return copies and do not mutate the transform.

namespace TS_FTransform_Queries_02
{
	bool Observe_GetDeterminant_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
		return FTransform::Identity.GetDeterminant() == 1.0 && Scaled.GetDeterminant() == 24.0;
	}

	bool Observe_GetTranslation_Nominal()
	{
		FTransform Transform(FVector(1.0, 2.0, 3.0));
		return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
			FTransform::Identity.GetTranslation().IsNearlyZero();
	}

	bool Observe_GetScale3D_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
		return Scaled.GetScale3D().Equals(FVector(2.0, 3.0, 4.0)) &&
			FTransform::Identity.GetScale3D().Equals(FVector::OneVector);
	}

	bool Observe_GetRotation_Nominal()
	{
		FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
		return FTransform::Identity.GetRotation().Equals(FQuat::Identity) &&
			!Yaw90.GetRotation().Equals(FQuat::Identity);
	}
}
/** @end */
