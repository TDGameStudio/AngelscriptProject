// Purpose: Observe FTransform translation scaling, Accumulate, and
// position/vector transform helpers including no-scale variants.
// AS-facing API: ScaleTranslation(vector); ScaleTranslation(scalar);
// Accumulate; TransformPosition; TransformPositionNoScale;
// InverseTransformPosition; InverseTransformPositionNoScale; TransformVector;
// TransformVectorNoScale; InverseTransformVector.
// Inputs: Translation (1,2,3), scale (2,2,2), yaw 90, Identity, and local
// (1,0,0).
// Expected observations: Per-axis ScaleTranslation yields (2,2,3). Uniform
// *2 doubles translation. Accumulate of (1,0,0)/(2,2,2) writes those parts.
// Identity TransformPosition preserves. Scale 2 scales positions but
// NoScale does not. Inverse of +10 X maps 11 back to 1. Yaw 90 maps X to Y.
// Boundary/ownership: ScaleTranslation and Accumulate mutate the receiver.
// Transform* helpers return new vectors.

namespace TS_FTransform_Behavior_02
{
	bool Observe_ScaleTranslation_Nominal()
	{
		FTransform PerAxis(FVector(1.0, 2.0, 3.0));
		PerAxis.ScaleTranslation(FVector(2.0, 1.0, 1.0));
		FTransform Uniform(FVector(1.0, 2.0, 3.0));
		Uniform.ScaleTranslation(2.0);
		return PerAxis.GetTranslation().Equals(FVector(2.0, 2.0, 3.0)) &&
			Uniform.GetTranslation().Equals(FVector(2.0, 4.0, 6.0)) &&
			PerAxis.GetScale3D().Equals(FVector::OneVector);
	}

	bool Observe_Accumulate_Nominal()
	{
		FTransform Base = FTransform::Identity;
		FTransform Delta(FQuat::Identity, FVector(1.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		Base.Accumulate(Delta);
		return Base.GetTranslation().Equals(FVector(1.0, 0.0, 0.0)) &&
			Base.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
			Delta.GetTranslation().X == 1.0;
	}

	bool Observe_TransformPosition_Nominal()
	{
		FVector IdentityPos = FTransform::Identity.TransformPosition(FVector(1.0, 2.0, 3.0));
		FVector Translated = FTransform(FVector(10.0, 0.0, 0.0)).TransformPosition(FVector(1.0, 0.0, 0.0));
		FVector Scaled = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0)).TransformPosition(FVector(1.0, 0.0, 0.0));
		FVector Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformPosition(FVector::ForwardVector);
		return IdentityPos.Equals(FVector(1.0, 2.0, 3.0)) &&
			Translated.Equals(FVector(11.0, 0.0, 0.0)) &&
			Scaled.Equals(FVector(2.0, 0.0, 0.0)) &&
			Rotated.Equals(FVector::RightVector);
	}

	bool Observe_TransformPositionNoScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		FVector WithoutScale = Scaled.TransformPositionNoScale(FVector(1.0, 0.0, 0.0));
		return WithoutScale.Equals(FVector(11.0, 0.0, 0.0));
	}

	bool Observe_InverseTransformPosition_Nominal()
	{
		FTransform Moved(FVector(10.0, 0.0, 0.0));
		FVector Local = Moved.InverseTransformPosition(FVector(11.0, 0.0, 0.0));
		FVector IdentityLocal = FTransform::Identity.InverseTransformPosition(FVector(1.0, 2.0, 3.0));
		return Local.Equals(FVector(1.0, 0.0, 0.0)) && IdentityLocal.Equals(FVector(1.0, 2.0, 3.0));
	}

	bool Observe_InverseTransformPositionNoScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		FVector Local = Scaled.InverseTransformPositionNoScale(FVector(11.0, 0.0, 0.0));
		return Local.Equals(FVector(1.0, 0.0, 0.0));
	}

	bool Observe_TransformVector_Nominal()
	{
		FVector Translated = FTransform(FVector(10.0, 0.0, 0.0)).TransformVector(FVector::ForwardVector);
		FVector Scaled = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0)).TransformVector(FVector::ForwardVector);
		FVector Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformVector(FVector::ForwardVector);
		return Translated.Equals(FVector::ForwardVector) &&
			Scaled.Equals(FVector(2.0, 0.0, 0.0)) &&
			Rotated.Equals(FVector::RightVector);
	}

	bool Observe_TransformVectorNoScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
		FVector WithoutScale = Scaled.TransformVectorNoScale(FVector::ForwardVector);
		FVector Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformVectorNoScale(FVector::ForwardVector);
		return WithoutScale.Equals(FVector::ForwardVector) && Rotated.Equals(FVector::RightVector);
	}

	bool Observe_InverseTransformVector_Nominal()
	{
		FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
		FVector Local = Yaw90.InverseTransformVector(FVector::RightVector);
		FVector Scaled = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0)).InverseTransformVector(FVector(2.0, 0.0, 0.0));
		return Local.Equals(FVector::ForwardVector) && Scaled.Equals(FVector::ForwardVector);
	}
}
