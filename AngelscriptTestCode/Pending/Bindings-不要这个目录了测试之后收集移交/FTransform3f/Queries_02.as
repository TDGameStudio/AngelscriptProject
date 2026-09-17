/**
 * @version v1
 * @summary Observe FTransform3f determinant, translation, scale, and rotation accessors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform3f determinant, translation, scale, and rotation accessors.
 * @topic Baseline
 */
// is 24. GetTranslation matches the constructor. Identity scale is OneVector.
// Identity rotation is Identity quat.
// Boundary/ownership: Accessors return copies and do not mutate the transform.

namespace TS_FTransform3f_Queries_02
{
	bool Observe_GetDeterminant_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
		return FTransform3f::Identity.GetDeterminant() == 1.0 && Scaled.GetDeterminant() == 24.0;
	}

	bool Observe_GetTranslation_Nominal()
	{
		FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
		return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
			FTransform3f::Identity.GetTranslation().IsNearlyZero();
	}

	bool Observe_GetScale3D_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
		return Scaled.GetScale3D().Equals(FVector3f(2.0, 3.0, 4.0)) &&
			FTransform3f::Identity.GetScale3D().Equals(FVector3f::OneVector);
	}

	bool Observe_GetRotation_Nominal()
	{
		FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
		return FTransform3f::Identity.GetRotation().Equals(FQuat4f::Identity) &&
			!Yaw90.GetRotation().Equals(FQuat4f::Identity);
	}
}
/** @end */
