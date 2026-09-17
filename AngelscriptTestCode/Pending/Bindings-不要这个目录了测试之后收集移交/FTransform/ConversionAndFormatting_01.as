/**
 * @version v1
 * @summary Observe FTransform matrix conversions with and without scale.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform matrix conversions with and without scale.
 * @topic Baseline
 */
// ToMatrixWithScale max axis > 1.5. ToMatrixNoScale max axis is near 1.
// Inverse matrix maps (10,0,0) back to the origin.
// Boundary/ownership: Matrix conversions return new matrices. They do not
// mutate the transform.

namespace TS_FTransform_ConversionAndFormatting_01
{
	bool Observe_ToMatrixWithScale_Nominal()
	{
		FTransform Moved(FVector(10.0, 0.0, 0.0));
		FMatrix WithTranslation = Moved.ToMatrixWithScale();
		FVector Origin = WithTranslation.GetOrigin();
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0));
		FMatrix WithScale = Scaled.ToMatrixWithScale();
		FMatrix IdentityMatrix = FTransform::Identity.ToMatrixWithScale();
		return Origin.Equals(FVector(10.0, 0.0, 0.0)) &&
			WithScale.GetMaximumAxisScale() > 1.5 &&
			IdentityMatrix.GetOrigin().IsNearlyZero();
	}

	bool Observe_ToMatrixNoScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector(5.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		FMatrix NoScale = Scaled.ToMatrixNoScale();
		FVector Origin = NoScale.GetOrigin();
		return NoScale.GetMaximumAxisScale() < 1.1 && Origin.Equals(FVector(5.0, 0.0, 0.0));
	}

	bool Observe_ToInverseMatrixWithScale_Nominal()
	{
		FTransform Moved(FVector(10.0, 0.0, 0.0));
		FMatrix Inverse = Moved.ToInverseMatrixWithScale();
		FVector4 Back = Inverse.TransformPosition(FVector(10.0, 0.0, 0.0));
		FVector IdentityOrigin = FTransform::Identity.ToInverseMatrixWithScale().GetOrigin();
		return Back.X == 0.0 && Back.Y == 0.0 && Back.Z == 0.0 && IdentityOrigin.IsNearlyZero();
	}
}
/** @end */
