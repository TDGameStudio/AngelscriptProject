// Purpose: Observe FTransform3f BlendWith, translation scaling, Accumulate,
// and position/vector transform helpers including no-scale variants.
// AS-facing API: BlendWith; ScaleTranslation(vector); ScaleTranslation(scalar);
// Accumulate; TransformPosition; TransformPositionNoScale;
// InverseTransformPosition; InverseTransformPositionNoScale; TransformVector;
// TransformVectorNoScale.
// Inputs: Blend translations 0 and 10, translation (1,2,3), scale (2,2,2),
// yaw 90, Identity, and local (1,0,0).
// Expected observations: BlendWith alpha 0 keeps the receiver; 1 replaces it.
// Per-axis ScaleTranslation yields (2,2,3). Accumulate writes translation and
// scale. Identity TransformPosition preserves. Scale 2 scales positions but
// NoScale does not. Inverse of +10 X maps 11 back to 1. Yaw 90 maps X to Y.
// Boundary/ownership: BlendWith, ScaleTranslation, and Accumulate mutate the
// receiver. Transform* helpers return new vectors.

namespace TS_FTransform3f_Behavior_02
{
	bool Observe_BlendWith_Nominal()
	{
		FTransform3f Current(FVector3f::ZeroVector);
		FTransform3f Other(FVector3f(10.0, 0.0, 0.0));
		Current.BlendWith(Other, 0.0);
		bool bKept = Current.GetTranslation().IsNearlyZero();
		Current.BlendWith(Other, 1.0);
		return bKept && Current.GetTranslation().Equals(FVector3f(10.0, 0.0, 0.0)) && Other.GetTranslation().X == 10.0;
	}

	bool Observe_ScaleTranslation_Nominal()
	{
		FTransform3f PerAxis(FVector3f(1.0, 2.0, 3.0));
		PerAxis.ScaleTranslation(FVector3f(2.0, 1.0, 1.0));
		FTransform3f Uniform(FVector3f(1.0, 2.0, 3.0));
		Uniform.ScaleTranslation(2.0);
		return PerAxis.GetTranslation().Equals(FVector3f(2.0, 2.0, 3.0)) &&
			Uniform.GetTranslation().Equals(FVector3f(2.0, 4.0, 6.0)) &&
			PerAxis.GetScale3D().Equals(FVector3f::OneVector);
	}

	bool Observe_Accumulate_Nominal()
	{
		FTransform3f Base = FTransform3f::Identity;
		FTransform3f Delta(FQuat4f::Identity, FVector3f(1.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
		Base.Accumulate(Delta);
		return Base.GetTranslation().Equals(FVector3f(1.0, 0.0, 0.0)) &&
			Base.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
			Delta.GetTranslation().X == 1.0;
	}

	bool Observe_TransformPosition_Nominal()
	{
		FVector3f IdentityPos = FTransform3f::Identity.TransformPosition(FVector3f(1.0, 2.0, 3.0));
		FVector3f Translated = FTransform3f(FVector3f(10.0, 0.0, 0.0)).TransformPosition(FVector3f(1.0, 0.0, 0.0));
		FVector3f Scaled = FTransform3f(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0)).TransformPosition(FVector3f(1.0, 0.0, 0.0));
		FVector3f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformPosition(FVector3f::ForwardVector);
		return IdentityPos.Equals(FVector3f(1.0, 2.0, 3.0)) &&
			Translated.Equals(FVector3f(11.0, 0.0, 0.0)) &&
			Scaled.Equals(FVector3f(2.0, 0.0, 0.0)) &&
			Rotated.Equals(FVector3f::RightVector);
	}

	bool Observe_TransformPositionNoScale_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
		FVector3f WithoutScale = Scaled.TransformPositionNoScale(FVector3f(1.0, 0.0, 0.0));
		return WithoutScale.Equals(FVector3f(11.0, 0.0, 0.0));
	}

	bool Observe_InverseTransformPosition_Nominal()
	{
		FTransform3f Moved(FVector3f(10.0, 0.0, 0.0));
		FVector3f Local = Moved.InverseTransformPosition(FVector3f(11.0, 0.0, 0.0));
		FVector3f IdentityLocal = FTransform3f::Identity.InverseTransformPosition(FVector3f(1.0, 2.0, 3.0));
		return Local.Equals(FVector3f(1.0, 0.0, 0.0)) && IdentityLocal.Equals(FVector3f(1.0, 2.0, 3.0));
	}

	bool Observe_InverseTransformPositionNoScale_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
		FVector3f Local = Scaled.InverseTransformPositionNoScale(FVector3f(11.0, 0.0, 0.0));
		return Local.Equals(FVector3f(1.0, 0.0, 0.0));
	}

	bool Observe_TransformVector_Nominal()
	{
		FVector3f Translated = FTransform3f(FVector3f(10.0, 0.0, 0.0)).TransformVector(FVector3f::ForwardVector);
		FVector3f Scaled = FTransform3f(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0)).TransformVector(FVector3f::ForwardVector);
		FVector3f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformVector(FVector3f::ForwardVector);
		return Translated.Equals(FVector3f::ForwardVector) &&
			Scaled.Equals(FVector3f(2.0, 0.0, 0.0)) &&
			Rotated.Equals(FVector3f::RightVector);
	}

	bool Observe_TransformVectorNoScale_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
		FVector3f WithoutScale = Scaled.TransformVectorNoScale(FVector3f::ForwardVector);
		FVector3f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformVectorNoScale(FVector3f::ForwardVector);
		return WithoutScale.Equals(FVector3f::ForwardVector) && Rotated.Equals(FVector3f::RightVector);
	}
}
