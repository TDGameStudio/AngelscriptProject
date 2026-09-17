/**
 * @version v1
 * @summary Observe remaining FTransform3f rotation helpers, translation compare, rotator conversion, concatenation, and InitFromString.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FTransform3f rotation helpers, translation compare, rotator conversion, concatenation, and InitFromString.
 * @topic Baseline
 */
// TransformRotation; InverseTransformRotation; SubtractTranslations;
// NormalizeRotation; TranslationEquals; Rotator; ConcatenateRotation;
// InitFromString.
// Inputs: Yaw 90, scale 2, Identity, translation (5,0,0) vs (2,0,0), ToString
// round-trip text, and empty text.
// Expected observations: InverseTransformVector of yaw 90 maps Y to X and
// undoes scale 2. Identity TransformRotation preserves a quat. Subtract
// translations X is 3. NormalizeRotation keeps Identity valid. Translation
// Equals ignores scale. Rotator of yaw 90 is (0,90,0). ConcatenateRotation of
// yaw 90 writes that yaw. InitFromString succeeds on formatter text and fails
// on empty.
// Boundary/ownership: NormalizeRotation and ConcatenateRotation mutate the
// receiver. InitFromString mutates and reports success.

namespace TS_FTransform3f_Behavior_03
{
	bool Observe_InverseTransformVector_Nominal()
	{
		FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
		FVector3f Local = Yaw90.InverseTransformVector(FVector3f::RightVector);
		FVector3f Scaled = FTransform3f(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0)).InverseTransformVector(FVector3f(2.0, 0.0, 0.0));
		return Local.Equals(FVector3f::ForwardVector) && Scaled.Equals(FVector3f::ForwardVector);
	}

	bool Observe_InverseTransformVectorNoScale_Nominal()
	{
		FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
		FVector3f Local = Yaw90.InverseTransformVectorNoScale(FVector3f::RightVector);
		FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0));
		FVector3f Unscaled = Scaled.InverseTransformVectorNoScale(FVector3f(2.0, 0.0, 0.0));
		return Local.Equals(FVector3f::ForwardVector) && Unscaled.Equals(FVector3f(2.0, 0.0, 0.0));
	}

	bool Observe_TransformRotation_Nominal()
	{
		FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Preserved = FTransform3f::Identity.TransformRotation(Yaw90);
		FQuat4f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformRotation(FQuat4f::Identity);
		return Preserved.Equals(Yaw90) && !Rotated.Equals(FQuat4f::Identity);
	}

	bool Observe_InverseTransformRotation_Nominal()
	{
		FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Preserved = FTransform3f::Identity.InverseTransformRotation(Yaw90);
		FQuat4f Local = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).InverseTransformRotation(Yaw90);
		return Preserved.Equals(Yaw90) && Local.Equals(FQuat4f::Identity);
	}

	bool Observe_SubtractTranslations_Nominal()
	{
		FTransform3f Left(FVector3f(5.0, 0.0, 0.0));
		FTransform3f Right(FVector3f(2.0, 0.0, 0.0));
		FVector3f Difference = Left.SubtractTranslations(Right);
		FVector3f VsIdentity = Left.SubtractTranslations(FTransform3f::Identity);
		return Difference.Equals(FVector3f(3.0, 0.0, 0.0)) && VsIdentity.Equals(FVector3f(5.0, 0.0, 0.0));
	}

	bool Observe_NormalizeRotation_Nominal()
	{
		FTransform3f Identity = FTransform3f::Identity;
		Identity.NormalizeRotation();
		FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
		Yaw90.NormalizeRotation();
		return Identity.IsRotationNormalized() &&
			Yaw90.IsRotationNormalized() &&
			Yaw90.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}

	bool Observe_TranslationEquals_Nominal()
	{
		FTransform3f Base(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		FTransform3f Moved(FVector3f(9.0, 0.0, 0.0));
		return Base.TranslationEquals(Scaled) &&
			Base.TranslationEquals(Scaled, __KINDA_SMALL_NUMBER_flt) &&
			!Base.TranslationEquals(Moved);
	}

	bool Observe_Rotator_Nominal()
	{
		FRotator3f IdentityRot = FTransform3f::Identity.Rotator();
		FRotator3f Yaw90 = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).Rotator();
		return IdentityRot.Equals(FRotator3f::ZeroRotator) && Yaw90.Equals(FRotator3f(0.0, 90.0, 0.0));
	}

	bool Observe_ConcatenateRotation_Nominal()
	{
		FTransform3f Transform = FTransform3f::Identity;
		Transform.ConcatenateRotation(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
		return Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}

	bool Observe_InitFromString_Nominal()
	{
		FTransform3f Source(FRotator3f(0.0, 90.0, 0.0), FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
		FString Text = f"{Source}";
		FTransform3f Parsed;
		bool bValid = Parsed.InitFromString(Text);
		FTransform3f Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bValid && Parsed.Equals(Source) && !bEmptyFailed;
	}
}
/** @end */
