/**
 * @version v1
 * @summary Observe remaining FTransform rotation helpers, translation compare, rotator conversion, concatenation, and InitFromString.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FTransform rotation helpers, translation compare, rotator conversion, concatenation, and InitFromString.
 * @topic Baseline
 */
// InverseTransformRotation; SubtractTranslations; NormalizeRotation;
// TranslationEquals; Rotator; ConcatenateRotation; InitFromString.
// Inputs: Yaw 90, scale 2, Identity, translation (5,0,0) vs (2,0,0), ToString
// round-trip text, and empty text.
// Expected observations: InverseTransformVectorNoScale of yaw 90 maps Y to X.
// Identity TransformRotation preserves a quat. SubtractTranslations X is 3.
// NormalizeRotation keeps Identity valid. TranslationEquals ignores scale.
// Rotator of yaw 90 is (0,90,0). ConcatenateRotation of yaw 90 writes that
// yaw. InitFromString succeeds on ToString text and fails on empty.
// Boundary/ownership: NormalizeRotation and ConcatenateRotation mutate the
// receiver. InitFromString mutates and reports success.

namespace TS_FTransform_Behavior_03
{
	bool Observe_InverseTransformVectorNoScale_Nominal()
	{
		FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
		FVector Local = Yaw90.InverseTransformVectorNoScale(FVector::RightVector);
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0));
		FVector Unscaled = Scaled.InverseTransformVectorNoScale(FVector(2.0, 0.0, 0.0));
		return Local.Equals(FVector::ForwardVector) && Unscaled.Equals(FVector(2.0, 0.0, 0.0));
	}

	bool Observe_TransformRotation_Nominal()
	{
		FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
		FQuat Preserved = FTransform::Identity.TransformRotation(Yaw90);
		FQuat Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformRotation(FQuat::Identity);
		return Preserved.Equals(Yaw90) && !Rotated.Equals(FQuat::Identity);
	}

	bool Observe_InverseTransformRotation_Nominal()
	{
		FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
		FQuat Preserved = FTransform::Identity.InverseTransformRotation(Yaw90);
		FQuat Local = FTransform(FRotator(0.0, 90.0, 0.0)).InverseTransformRotation(Yaw90);
		return Preserved.Equals(Yaw90) && Local.Equals(FQuat::Identity);
	}

	bool Observe_SubtractTranslations_Nominal()
	{
		FTransform Left(FVector(5.0, 0.0, 0.0));
		FTransform Right(FVector(2.0, 0.0, 0.0));
		FVector Difference = Left.SubtractTranslations(Right);
		FVector VsIdentity = Left.SubtractTranslations(FTransform::Identity);
		return Difference.Equals(FVector(3.0, 0.0, 0.0)) && VsIdentity.Equals(FVector(5.0, 0.0, 0.0));
	}

	bool Observe_NormalizeRotation_Nominal()
	{
		FTransform Identity = FTransform::Identity;
		Identity.NormalizeRotation();
		FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
		Yaw90.NormalizeRotation();
		return Identity.IsRotationNormalized() &&
			Yaw90.IsRotationNormalized() &&
			Yaw90.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}

	bool Observe_TranslationEquals_Nominal()
	{
		FTransform Base(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector::OneVector);
		FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		FTransform Moved(FVector(9.0, 0.0, 0.0));
		return Base.TranslationEquals(Scaled) &&
			Base.TranslationEquals(Scaled, KINDA_SMALL_NUMBER) &&
			!Base.TranslationEquals(Moved);
	}

	bool Observe_Rotator_Nominal()
	{
		FRotator IdentityRot = FTransform::Identity.Rotator();
		FRotator Yaw90 = FTransform(FRotator(0.0, 90.0, 0.0)).Rotator();
		return IdentityRot.Equals(FRotator::ZeroRotator) && Yaw90.Equals(FRotator(0.0, 90.0, 0.0));
	}

	bool Observe_ConcatenateRotation_Nominal()
	{
		FTransform Transform = FTransform::Identity;
		Transform.ConcatenateRotation(FQuat(FRotator(0.0, 90.0, 0.0)));
		return Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}

	bool Observe_InitFromString_Nominal()
	{
		FTransform Source(FRotator(0.0, 90.0, 0.0), FVector(1.0, 2.0, 3.0), FVector::OneVector);
		FString Text = f"{Source}";
		FTransform Parsed;
		bool bValid = Parsed.InitFromString(Text);
		FTransform Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bValid && Parsed.Equals(Source) && !bEmptyFailed;
	}
}
/** @end */
