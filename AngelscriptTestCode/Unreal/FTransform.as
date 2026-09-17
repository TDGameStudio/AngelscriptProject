/**
 * @version v1
 * @summary FTransform host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FTransform
 *
 * transform
 * inverse
 * blend
 * blend-with
 * scale-translation
 * accumulate
 * transform-position
 * transform-position-no-scale
 * inverse-transform-position
 * inverse-transform-position-no-scale
 * transform-vector
 * transform-vector-no-scale
 * inverse-transform-vector
 * inverse-transform-vector-no-scale
 * transform-rotation
 * inverse-transform-rotation
 * subtract-translations
 * normalize-rotation
 * translation-equals
 * rotator
 * concatenate-rotation
 * init-from-string
 * assignment
 * multiply-assign
 * to-matrix-with-scale
 * to-matrix-no-scale
 * to-inverse-matrix-with-scale
 * remove-scaling
 * set-to-relative-transform
 * set-location
 * set-translation
 * add-to-translation
 * set-rotation
 * set-scale-3-d
 * set-translation-and-scale-3-d
 * surface-003
 * FTransform-NamespaceAndGlobalFunctions_01-transform
 * get-maximum-axis-scale
 * get-minimum-axis-scale
 * get-relative-transform
 * get-relative-transform-reverse
 * is-rotation-normalized
 * equals-no-scale
 * equals
 * get-location
 * contains-na-n
 * is-valid
 * get-determinant
 * get-translation
 * get-scale-3-d
 * get-rotation
 * construction
 * operations
 * render-transform-null-guard
 * transform-advanced-methods-and-mutators
 * transform-comparison
 * transform-composition
 * transform-construction
 * transform-interpolation
 * transform-inverse
 * transform-member-access
 * transform-position-and-vector
 * container-properties
 * declaration-defaults
 * member-access
 * write-round-trip
 * function-default-parameters
 * function-parameters-in
 * function-parameters-in-out
 * function-parameters-out
 * function-parameters-value
 * function-return-values

 */
/**
 * @begin transform
 * @summary world axes plus translation, FTransform3f conversion,
 * @topic Unreal
 */
/**
 * @function ObserveTransformNominal
 * @summary world axes plus translation, FTransform3f conversion,
 * @covers FTransform.transform
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform3f conversion,

 Inverse of (10,0,0),
// blend translations 0 and 10 at alpha 0/0.5/1.
// Expected observations: Default equals Identity. Copy is independent.
// Translation/quat/rotator/axes/FTransform3f store the supplied parts. Inverse
// of +10 X is -10 X. Blend alpha 0/1 selects endpoints; 0.5 is midpoint.
// BlendWith alpha 0 keeps the receiver.
// Boundary/ownership: Inverse/Blend results do not mutate the source atoms.
// Blend and BlendWith mutate the receiver.
bool ObserveTransformNominal()
{
	FTransform DefaultTransform;
	FTransform Copied(FTransform(FVector(1.0, 2.0, 3.0)));
	FTransform FromTranslation(FVector(1.0, 2.0, 3.0));
	FTransform FromQuat(FQuat::Identity);
	FTransform FromRotator(FRotator(0.0, 90.0, 0.0));
	FTransform FromAxes(FVector::ForwardVector, FVector::RightVector, FVector::UpVector, FVector(4.0, 5.0, 6.0));
	FTransform3f Single(FVector3f(7.0, 8.0, 9.0));
	FTransform FromSingle(Single);
	FTransform Original = Copied;
	Copied.SetTranslation(FVector::ZeroVector);
	return DefaultTransform.Equals(FTransform::Identity) &&
		Original.GetTranslation().X == 1.0 &&
		FromTranslation.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
		FromQuat.GetRotation().Equals(FQuat::Identity) &&
		FromRotator.Rotator().Equals(FRotator(0.0, 90.0, 0.0)) &&
		FromAxes.GetTranslation().Equals(FVector(4.0, 5.0, 6.0)) &&
		FromAxes.GetRotation().Equals(FQuat::Identity) &&
		FromSingle.GetTranslation().Equals(FVector(7.0, 8.0, 9.0));
}
/** @end */
/**
 * @begin inverse
 * @summary Blend and BlendWith mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInverseNominal
 * @summary Blend and BlendWith mutate the receiver.
 * @covers FTransform.inverse
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform3f conversion,

bool ObserveInverseNominal()
{
	FTransform Moved(FVector(10.0, 0.0, 0.0));
	FTransform Inverse = Moved.Inverse();
	FTransform IdentityInverse = FTransform::Identity.Inverse();
	return Inverse.GetTranslation().Equals(FVector(-10.0, 0.0, 0.0)) &&
		IdentityInverse.Equals(FTransform::Identity) &&
		Moved.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin blend
 * @summary Blend and BlendWith mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveBlendNominal
 * @summary Blend and BlendWith mutate the receiver.
 * @covers FTransform.blend
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform3f conversion,

bool ObserveBlendNominal()
{
	FTransform Atom1(FVector::ZeroVector);
	FTransform Atom2(FVector(10.0, 0.0, 0.0));
	FTransform Blended;
	Blended.Blend(Atom1, Atom2, 0.0);
	bool bAlpha0 = Blended.GetTranslation().IsNearlyZero();
	Blended.Blend(Atom1, Atom2, 1.0);
	bool bAlpha1 = Blended.GetTranslation().Equals(FVector(10.0, 0.0, 0.0));
	Blended.Blend(Atom1, Atom2, 0.5);
	bool bAlphaHalf = Blended.GetTranslation().Equals(FVector(5.0, 0.0, 0.0));
	return bAlpha0 && bAlpha1 && bAlphaHalf && Atom2.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin blend-with
 * @summary Blend and BlendWith mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveBlendWithNominal
 * @summary Blend and BlendWith mutate the receiver.
 * @covers FTransform.blend-with
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform3f conversion,

bool ObserveBlendWithNominal()
{
	FTransform Current(FVector::ZeroVector);
	FTransform Other(FVector(10.0, 0.0, 0.0));
	Current.BlendWith(Other, 0.0);
	bool bKept = Current.GetTranslation().IsNearlyZero();
	Current.BlendWith(Other, 1.0);
	return bKept && Current.GetTranslation().Equals(FVector(10.0, 0.0, 0.0)) && Other.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin scale-translation
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveScaleTranslationNominal
 * @summary Observe the container API.
 * @covers FTransform.scale-translation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Translation (1,2,3), scale (2,2,2), yaw 90, Identity, and local
// (1,0,0).
// Expected observations: Per-axis ScaleTranslation yields (2,2,3). Uniform
// *2 doubles translation. Accumulate of (1,0,0)/(2,2,2) writes those parts.
// Identity TransformPosition preserves. Scale 2 scales positions but
// NoScale does not. Inverse of +10 X maps 11 back to 1. Yaw 90 maps X to Y.
// Boundary/ownership: ScaleTranslation and Accumulate mutate the receiver.
// Transform* helpers return new vectors.
bool ObserveScaleTranslationNominal()
{
	FTransform PerAxis(FVector(1.0, 2.0, 3.0));
	PerAxis.ScaleTranslation(FVector(2.0, 1.0, 1.0));
	FTransform Uniform(FVector(1.0, 2.0, 3.0));
	Uniform.ScaleTranslation(2.0);
	return PerAxis.GetTranslation().Equals(FVector(2.0, 2.0, 3.0)) &&
		Uniform.GetTranslation().Equals(FVector(2.0, 4.0, 6.0)) &&
		PerAxis.GetScale3D().Equals(FVector::OneVector);
}
/** @end */
/**
 * @begin accumulate
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveAccumulateNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.accumulate
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAccumulateNominal()
{
	FTransform Base = FTransform::Identity;
	FTransform Delta(FQuat::Identity, FVector(1.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	Base.Accumulate(Delta);
	return Base.GetTranslation().Equals(FVector(1.0, 0.0, 0.0)) &&
		Base.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
		Delta.GetTranslation().X == 1.0;
}
/** @end */
/**
 * @begin transform-position
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveTransformPositionNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.transform-position
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformPositionNominal()
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
/** @end */
/**
 * @begin transform-position-no-scale
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveTransformPositionNoScaleNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.transform-position-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformPositionNoScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	FVector WithoutScale = Scaled.TransformPositionNoScale(FVector(1.0, 0.0, 0.0));
	return WithoutScale.Equals(FVector(11.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin inverse-transform-position
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformPositionNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.inverse-transform-position
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseTransformPositionNominal()
{
	FTransform Moved(FVector(10.0, 0.0, 0.0));
	FVector Local = Moved.InverseTransformPosition(FVector(11.0, 0.0, 0.0));
	FVector IdentityLocal = FTransform::Identity.InverseTransformPosition(FVector(1.0, 2.0, 3.0));
	return Local.Equals(FVector(1.0, 0.0, 0.0)) && IdentityLocal.Equals(FVector(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin inverse-transform-position-no-scale
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformPositionNoScaleNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.inverse-transform-position-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseTransformPositionNoScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	FVector Local = Scaled.InverseTransformPositionNoScale(FVector(11.0, 0.0, 0.0));
	return Local.Equals(FVector(1.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin transform-vector
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveTransformVectorNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.transform-vector
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformVectorNominal()
{
	FVector Translated = FTransform(FVector(10.0, 0.0, 0.0)).TransformVector(FVector::ForwardVector);
	FVector Scaled = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0)).TransformVector(FVector::ForwardVector);
	FVector Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformVector(FVector::ForwardVector);
	return Translated.Equals(FVector::ForwardVector) &&
		Scaled.Equals(FVector(2.0, 0.0, 0.0)) &&
		Rotated.Equals(FVector::RightVector);
}
/** @end */
/**
 * @begin transform-vector-no-scale
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveTransformVectorNoScaleNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.transform-vector-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTransformVectorNoScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector(10.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	FVector WithoutScale = Scaled.TransformVectorNoScale(FVector::ForwardVector);
	FVector Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformVectorNoScale(FVector::ForwardVector);
	return WithoutScale.Equals(FVector::ForwardVector) && Rotated.Equals(FVector::RightVector);
}
/** @end */
/**
 * @begin inverse-transform-vector
 * @summary Transform* helpers return new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformVectorNominal
 * @summary Transform* helpers return new vectors.
 * @covers FTransform.inverse-transform-vector
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseTransformVectorNominal()
{
	FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
	FVector Local = Yaw90.InverseTransformVector(FVector::RightVector);
	FVector Scaled = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0)).InverseTransformVector(FVector(2.0, 0.0, 0.0));
	return Local.Equals(FVector::ForwardVector) && Scaled.Equals(FVector::ForwardVector);
}
/** @end */
/**
 * @begin inverse-transform-vector-no-scale
 * @summary Rotator of yaw
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformVectorNoScaleNominal
 * @summary Rotator of yaw
 * @covers FTransform.inverse-transform-vector-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

 90 is (0,90,0). ConcatenateRotation of yaw 90 writes that
// yaw. InitFromString succeeds on ToString text and fails on empty.
// Boundary/ownership: NormalizeRotation and ConcatenateRotation mutate the
// receiver. InitFromString mutates and reports success.
bool ObserveInverseTransformVectorNoScaleNominal()
{
	FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
	FVector Local = Yaw90.InverseTransformVectorNoScale(FVector::RightVector);
	FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 2.0, 2.0));
	FVector Unscaled = Scaled.InverseTransformVectorNoScale(FVector(2.0, 0.0, 0.0));
	return Local.Equals(FVector::ForwardVector) && Unscaled.Equals(FVector(2.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin transform-rotation
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTransformRotationNominal
 * @summary receiver.
 * @covers FTransform.transform-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveTransformRotationNominal()
{
	FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
	FQuat Preserved = FTransform::Identity.TransformRotation(Yaw90);
	FQuat Rotated = FTransform(FRotator(0.0, 90.0, 0.0)).TransformRotation(FQuat::Identity);
	return Preserved.Equals(Yaw90) && !Rotated.Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin inverse-transform-rotation
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformRotationNominal
 * @summary receiver.
 * @covers FTransform.inverse-transform-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveInverseTransformRotationNominal()
{
	FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
	FQuat Preserved = FTransform::Identity.InverseTransformRotation(Yaw90);
	FQuat Local = FTransform(FRotator(0.0, 90.0, 0.0)).InverseTransformRotation(Yaw90);
	return Preserved.Equals(Yaw90) && Local.Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin subtract-translations
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractTranslationsNominal
 * @summary receiver.
 * @covers FTransform.subtract-translations
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveSubtractTranslationsNominal()
{
	FTransform Left(FVector(5.0, 0.0, 0.0));
	FTransform Right(FVector(2.0, 0.0, 0.0));
	FVector Difference = Left.SubtractTranslations(Right);
	FVector VsIdentity = Left.SubtractTranslations(FTransform::Identity);
	return Difference.Equals(FVector(3.0, 0.0, 0.0)) && VsIdentity.Equals(FVector(5.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin normalize-rotation
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeRotationNominal
 * @summary receiver.
 * @covers FTransform.normalize-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveNormalizeRotationNominal()
{
	FTransform Identity = FTransform::Identity;
	Identity.NormalizeRotation();
	FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
	Yaw90.NormalizeRotation();
	return Identity.IsRotationNormalized() &&
		Yaw90.IsRotationNormalized() &&
		Yaw90.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin translation-equals
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTranslationEqualsNominal
 * @summary receiver.
 * @covers FTransform.translation-equals
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveTranslationEqualsNominal()
{
	FTransform Base(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector::OneVector);
	FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	FTransform Moved(FVector(9.0, 0.0, 0.0));
	return Base.TranslationEquals(Scaled) &&
		Base.TranslationEquals(Scaled, KINDA_SMALL_NUMBER) &&
		!Base.TranslationEquals(Moved);
}
/** @end */
/**
 * @begin rotator
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary receiver.
 * @covers FTransform.rotator
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveRotatorNominal()
{
	FRotator IdentityRot = FTransform::Identity.Rotator();
	FRotator Yaw90 = FTransform(FRotator(0.0, 90.0, 0.0)).Rotator();
	return IdentityRot.Equals(FRotator::ZeroRotator) && Yaw90.Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin concatenate-rotation
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveConcatenateRotationNominal
 * @summary receiver.
 * @covers FTransform.concatenate-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveConcatenateRotationNominal()
{
	FTransform Transform = FTransform::Identity;
	Transform.ConcatenateRotation(FQuat(FRotator(0.0, 90.0, 0.0)));
	return Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin init-from-string
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary receiver.
 * @covers FTransform.init-from-string
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Rotator of yaw

bool ObserveInitFromStringNominal()
{
	FTransform Source(FRotator(0.0, 90.0, 0.0), FVector(1.0, 2.0, 3.0), FVector::OneVector);
	FString Text = f"{Source}";
	FTransform Parsed;
	bool bValid = Parsed.InitFromString(Text);
	FTransform Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bValid && Parsed.Equals(Source) && !bEmptyFailed;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: * returns a new transform.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: * returns a new transform.
 * @covers FTransform.assignment
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAssignmentNominal()
{
	FTransform Left;
	FTransform Right(FVector(1.0, 0.0, 0.0));
	FTransform Original = Right;
	Left = Right;
	FTransform Combined = Left * FTransform(FVector(2.0, 0.0, 0.0));
	FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
	FTransform Rotated = FTransform::Identity * Yaw90;
	Right.SetTranslation(FVector(9.0, 0.0, 0.0));
	FString Text = f"{Left}";
	return Left.GetTranslation().X == 1.0 &&
		Combined.GetTranslation().X == 3.0 &&
		Rotated.Rotator().Equals(FRotator(0.0, 90.0, 0.0)) &&
		Original.GetTranslation().X == 1.0 &&
		Text.Len() > 0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Boundary/ownership: * returns a new transform.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Boundary/ownership: * returns a new transform.
 * @covers FTransform.multiply-assign
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveMultiplyAssignNominal()
{
	FTransform Transform(FVector(1.0, 0.0, 0.0));
	Transform *= FTransform(FVector(2.0, 0.0, 0.0));
	FTransform Rotated = FTransform::Identity;
	Rotated *= FQuat(FRotator(0.0, 90.0, 0.0));
	return Transform.GetTranslation().X == 3.0 && Rotated.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin to-matrix-with-scale
 * @summary Inverse
 * @topic Unreal
 */
/**
 * @function ObserveToMatrixWithScaleNominal
 * @summary Inverse
 * @covers FTransform.to-matrix-with-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inverse

 matrix maps (10,0,0) back to the origin.
// Boundary/ownership: Matrix conversions return new matrices. They do not
// mutate the transform.
bool ObserveToMatrixWithScaleNominal()
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
/** @end */
/**
 * @begin to-matrix-no-scale
 * @summary mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveToMatrixNoScaleNominal
 * @summary mutate the transform.
 * @covers FTransform.to-matrix-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inverse

bool ObserveToMatrixNoScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector(5.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	FMatrix NoScale = Scaled.ToMatrixNoScale();
	FVector Origin = NoScale.GetOrigin();
	return NoScale.GetMaximumAxisScale() < 1.1 && Origin.Equals(FVector(5.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin to-inverse-matrix-with-scale
 * @summary mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveToInverseMatrixWithScaleNominal
 * @summary mutate the transform.
 * @covers FTransform.to-inverse-matrix-with-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inverse

bool ObserveToInverseMatrixWithScaleNominal()
{
	FTransform Moved(FVector(10.0, 0.0, 0.0));
	FMatrix Inverse = Moved.ToInverseMatrixWithScale();
	FVector4 Back = Inverse.TransformPosition(FVector(10.0, 0.0, 0.0));
	FVector IdentityOrigin = FTransform::Identity.ToInverseMatrixWithScale().GetOrigin();
	return Back.X == 0.0 && Back.Y == 0.0 && Back.Z == 0.0 && IdentityOrigin.IsNearlyZero();
}
/** @end */
/**
 * @begin remove-scaling
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveScalingNominal
 * @summary Observe the container API.
 * @covers FTransform.remove-scaling
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Scale (2,2,2), child 13 vs parent 10, location (1,2,3), add (1,0,0),
// yaw-90 quat, default SMALL_NUMBER, and a repeated SetLocation.
// Expected observations: RemoveScaling restores unit scale. Relative rewrite
// yields X=3. SetLocation/SetTranslation write GetLocation. AddToTranslation
// adds. SetRotation yields yaw 90. SetScale3D stores (2,3,4). Combined setter
// keeps rotation.
// Boundary/ownership: All listed methods mutate the receiver. RemoveScaling
// default tolerance is SMALL_NUMBER.
bool ObserveRemoveScalingNominal()
{
	FTransform Scaled(FQuat::Identity, FVector(1.0, 0.0, 0.0), FVector(2.0, 2.0, 2.0));
	Scaled.RemoveScaling();
	FTransform Explicit(FQuat::Identity, FVector::ZeroVector, FVector(3.0, 3.0, 3.0));
	Explicit.RemoveScaling(SMALL_NUMBER);
	return Scaled.GetScale3D().Equals(FVector::OneVector) &&
		Explicit.GetScale3D().Equals(FVector::OneVector) &&
		Scaled.GetTranslation().X == 1.0;
}
/** @end */
/**
 * @begin set-to-relative-transform
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetToRelativeTransformNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-to-relative-transform
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetToRelativeTransformNominal()
{
	FTransform Child(FVector(13.0, 0.0, 0.0));
	FTransform Parent(FVector(10.0, 0.0, 0.0));
	Child.SetToRelativeTransform(Parent);
	return Child.GetTranslation().Equals(FVector(3.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin set-location
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetLocationNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-location
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetLocationNominal()
{
	FTransform Transform = FTransform::Identity;
	Transform.SetLocation(FVector(1.0, 2.0, 3.0));
	Transform.SetLocation(FVector(4.0, 5.0, 6.0));
	return Transform.GetLocation().Equals(FVector(4.0, 5.0, 6.0));
}
/** @end */
/**
 * @begin set-translation
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetTranslationNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-translation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetTranslationNominal()
{
	FTransform Transform = FTransform::Identity;
	Transform.SetTranslation(FVector(1.0, 2.0, 3.0));
	return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin add-to-translation
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveAddToTranslationNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.add-to-translation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAddToTranslationNominal()
{
	FTransform Transform(FVector(1.0, 2.0, 3.0));
	Transform.AddToTranslation(FVector(1.0, 0.0, 0.0));
	Transform.AddToTranslation(FVector::ZeroVector);
	return Transform.GetTranslation().Equals(FVector(2.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin set-rotation
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetRotationNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetRotationNominal()
{
	FTransform Transform = FTransform::Identity;
	Transform.SetRotation(FQuat(FRotator(0.0, 90.0, 0.0)));
	return Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin set-scale-3-d
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetScale3DNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-scale-3-d
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetScale3DNominal()
{
	FTransform Transform = FTransform::Identity;
	Transform.SetScale3D(FVector(2.0, 3.0, 4.0));
	return Transform.GetScale3D().Equals(FVector(2.0, 3.0, 4.0));
}
/** @end */
/**
 * @begin set-translation-and-scale-3-d
 * @summary default tolerance is SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSetTranslationAndScale3DNominal
 * @summary default tolerance is SMALL_NUMBER.
 * @covers FTransform.set-translation-and-scale-3-d
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetTranslationAndScale3DNominal()
{
	FTransform Transform(FRotator(0.0, 90.0, 0.0));
	Transform.SetTranslationAndScale3D(FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
		Transform.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
		Transform.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin surface-003
 * @summary scale, and
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary scale, and
 * @covers FTransform.surface-003
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// scale, and

 explicit scale (2,2,2).
// Expected observations: Identity has zero translation and unit scale. Omitted
// scale is OneVector. Explicit scale is stored. Rotation constructors keep
// the supplied translation.
// Boundary/ownership: Identity is a shared constant. Omitted InScale3D is
// FVector::OneVector.
// FTransform::Identity: zero translation, identity rotation, unit scale. Shared constant.
bool ObserveSurface003Nominal()
{
	FTransform Identity = FTransform::Identity;
	return Identity.GetTranslation().IsNearlyZero() &&
		Identity.GetScale3D().Equals(FVector::OneVector) &&
		Identity.GetRotation().Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin FTransform-NamespaceAndGlobalFunctions_01-transform
 * @summary FTransform(Quat/Rotator, Translation, Scale=OneVector): omitted scale is OneVector.
 * @topic Unreal
 */
/**
 * @function ObserveTransformNominal
 * @summary FTransform(Quat/Rotator, Translation, Scale=OneVector): omitted scale is OneVector.
 * @covers FTransform.transform
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
// scale, and

bool ObserveTransformNominal()
{
	FTransform FromQuatDefault(FQuat::Identity, FVector(1.0, 2.0, 3.0));
	FTransform FromQuatScale(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	FTransform FromRotDefault(FRotator::ZeroRotator, FVector(1.0, 2.0, 3.0));
	FTransform FromRotScale(FRotator(0.0, 90.0, 0.0), FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	return FromQuatDefault.GetScale3D().Equals(FVector::OneVector) &&
		FromRotDefault.GetScale3D().Equals(FVector::OneVector) &&
		FromQuatScale.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
		FromRotScale.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
		FromQuatDefault.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
		FromRotScale.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin get-maximum-axis-scale
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaximumAxisScaleNominal
 * @summary Observe the container API.
 * @covers FTransform.get-maximum-axis-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Scale (2,3,4), Identity, child translation 13 vs parent 10, same
// rotation/translation with different scale, default KINDA_SMALL_NUMBER.
// Expected observations: Max scale is 4, min is 2. Relative translation X is
// 3. Identity rotation is normalized and valid. EqualsNoScale is true across
// scale; Equals is false. GetLocation matches translation. ContainsNaN is
// false.
// Boundary/ownership: Relative queries return new transforms. Equals uses
// tolerance.
bool ObserveGetMaximumAxisScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
	return Scaled.GetMaximumAxisScale() == 4.0 && FTransform::Identity.GetMaximumAxisScale() == 1.0;
}
/** @end */
/**
 * @begin get-minimum-axis-scale
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinimumAxisScaleNominal
 * @summary tolerance.
 * @covers FTransform.get-minimum-axis-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetMinimumAxisScaleNominal()
{
	FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
	return Scaled.GetMinimumAxisScale() == 2.0 && FTransform::Identity.GetMinimumAxisScale() == 1.0;
}
/** @end */
/**
 * @begin get-relative-transform
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetRelativeTransformNominal
 * @summary tolerance.
 * @covers FTransform.get-relative-transform
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetRelativeTransformNominal()
{
	FTransform Parent(FVector(10.0, 0.0, 0.0));
	FTransform Child(FVector(13.0, 0.0, 0.0));
	FTransform Relative = Child.GetRelativeTransform(Parent);
	FTransform VsIdentity = Child.GetRelativeTransform(FTransform::Identity);
	return Relative.GetTranslation().Equals(FVector(3.0, 0.0, 0.0)) &&
		VsIdentity.GetTranslation().Equals(FVector(13.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin get-relative-transform-reverse
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetRelativeTransformReverseNominal
 * @summary tolerance.
 * @covers FTransform.get-relative-transform-reverse
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetRelativeTransformReverseNominal()
{
	FTransform Parent(FVector(10.0, 0.0, 0.0));
	FTransform Child(FVector(13.0, 0.0, 0.0));
	FTransform Reverse = Parent.GetRelativeTransformReverse(Child);
	return Reverse.GetTranslation().Equals(FVector(3.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin is-rotation-normalized
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsRotationNormalizedNominal
 * @summary tolerance.
 * @covers FTransform.is-rotation-normalized
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsRotationNormalizedNominal()
{
	FTransform FromRotator(FRotator(0.0, 90.0, 0.0));
	return FTransform::Identity.IsRotationNormalized() && FromRotator.IsRotationNormalized();
}
/** @end */
/**
 * @begin equals-no-scale
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNoScaleNominal
 * @summary tolerance.
 * @covers FTransform.equals-no-scale
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualsNoScaleNominal()
{
	FTransform Base(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector::OneVector);
	FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	FTransform Moved(FQuat::Identity, FVector(9.0, 0.0, 0.0), FVector::OneVector);
	return Base.EqualsNoScale(Scaled) &&
		Base.EqualsNoScale(Scaled, KINDA_SMALL_NUMBER) &&
		!Base.EqualsNoScale(Moved);
}
/** @end */
/**
 * @begin equals
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary tolerance.
 * @covers FTransform.equals
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualsNominal()
{
	FTransform Left(FVector(1.0, 2.0, 3.0));
	FTransform Right(FVector(1.0, 2.0, 3.0));
	FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
	return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Scaled);
}
/** @end */
/**
 * @begin get-location
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetLocationNominal
 * @summary tolerance.
 * @covers FTransform.get-location
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetLocationNominal()
{
	FTransform Transform(FVector(1.0, 2.0, 3.0));
	return Transform.GetLocation().Equals(FVector(1.0, 2.0, 3.0)) &&
		FTransform::Identity.GetLocation().IsNearlyZero();
}
/** @end */
/**
 * @begin contains-na-n
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary tolerance.
 * @covers FTransform.contains-na-n
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveContainsNaNNominal()
{
	FTransform Translated(FVector(1.0, 2.0, 3.0));
	return !FTransform::Identity.ContainsNaN() && !Translated.ContainsNaN();
}
/** @end */
/**
 * @begin is-valid
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary tolerance.
 * @covers FTransform.is-valid
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsValidNominal()
{
	FTransform Translated(FVector(1.0, 2.0, 3.0));
	return FTransform::Identity.IsValid() && Translated.IsValid();
}
/** @end */
/**
 * @begin get-determinant
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveGetDeterminantNominal
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @covers FTransform.get-determinant
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDeterminantNominal()
{
	FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
	return FTransform::Identity.GetDeterminant() == 1.0 && Scaled.GetDeterminant() == 24.0;
}
/** @end */
/**
 * @begin get-translation
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveGetTranslationNominal
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @covers FTransform.get-translation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTranslationNominal()
{
	FTransform Transform(FVector(1.0, 2.0, 3.0));
	return Transform.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
		FTransform::Identity.GetTranslation().IsNearlyZero();
}
/** @end */
/**
 * @begin get-scale-3-d
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveGetScale3DNominal
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @covers FTransform.get-scale-3-d
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetScale3DNominal()
{
	FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
	return Scaled.GetScale3D().Equals(FVector(2.0, 3.0, 4.0)) &&
		FTransform::Identity.GetScale3D().Equals(FVector::OneVector);
}
/** @end */
/**
 * @begin get-rotation
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @topic Unreal
 */
/**
 * @function ObserveGetRotationNominal
 * @summary Boundary/ownership: Accessors return copies and do not mutate the transform.
 * @covers FTransform.get-rotation
 * @inputs FTransform values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRotationNominal()
{
	FTransform Yaw90(FRotator(0.0, 90.0, 0.0));
	return FTransform::Identity.GetRotation().Equals(FQuat::Identity) &&
		!Yaw90.GetRotation().Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin construction
 * @summary Observe that the default constructor yields the identity.
 * @topic Unreal
 */
/**
 * @function DefaultConstructionIsIdentity
 * @summary Observe that the default constructor yields the identity.
 * @covers FTransform.GeometricConstruction
 * @inputs none
 * @return true when the default equals identity
 */
bool DefaultConstructionIsIdentity()
{
	return TestDefaultConstruction().Equals(FTransform::Identity, 0.001);
}
/** @end */
/**
 * @begin operations
 * @summary Compare two transforms that share rotation and translation but differ in scale.
 * @topic Unreal
 */
/**
 * @function TestEqualsNoScale
 * @summary Compare two transforms that share rotation and translation but differ in scale.
 * @covers FTransform.GeometricOperations
 * @inputs none
 * @return true
 */
bool TestEqualsNoScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
	return A.EqualsNoScale(B, 0.001);
}
/** @end */
/**
 * @begin render-transform-null-guard
 * @summary Read a widget render transform and return a code for the matching fields.
 * @topic Unreal
 */
/**
 * @function ReadWidgetTransform
 * @summary Read a widget render transform and return a code for the matching fields.
 * @covers FTransform.RenderTransformNullGuard
 * @inputs a widget
 * @return 1 on match, 10 on translation mismatch, 20 on scale mismatch, 30 on angle mismatch
 */
int ReadWidgetTransform(UWidget Widget)
{
	const FWidgetTransform Transform = Widget.GetRenderTransform();
	if (Transform.Translation.X != 13.5f || Transform.Translation.Y != -9.25f)
	{
		return 10;
	}
	if (Transform.Scale.X != 1.25f || Transform.Scale.Y != 0.75f)
	{
		return 20;
	}
	if (Transform.Angle != 42.0f)
	{
		return 30;
	}
	return 1;
}
/** @end */
/**
 * @begin transform-advanced-methods-and-mutators
 * @summary Compare two transforms that share rotation and translation but differ in scale.
 * @topic Unreal
 */
/**
 * @function CompareNoScale
 * @summary Compare two transforms that share rotation and translation but differ in scale.
 * @covers FTransform.AdvancedMethodsAndMutators
 * @inputs none
 * @return true
 */
bool CompareNoScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
	return A.EqualsNoScale(B, 0.001);
}
/** @end */
/**
 * @begin transform-comparison
 * @summary Compare two identity transforms for equality.
 * @topic Unreal
 */
/**
 * @function CompareIdentity
 * @summary Compare two identity transforms for equality.
 * @covers FTransform.Comparison
 * @inputs none
 * @return true
 */
bool CompareIdentity()
{
	FTransform A = FTransform::Identity;
	FTransform B = FTransform::Identity;
	return A.Equals(B);
}
/** @end */
/**
 * @begin transform-composition
 * @summary Observe that two-transform composition matches the native product.
 * @topic Unreal
 */
/**
 * @function ComposeTransformsNominal
 * @summary Observe that two-transform composition matches the native product.
 * @covers FTransform.Composition
 * @inputs none
 * @return true when ComposeTransforms equals T1
 */
bool ComposeTransformsNominal()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 200, 0));
	return ComposeTransforms().Equals(T1 * T2, 0.001);
}
/** @end */
/**
 * @begin transform-construction
 * @summary Construct a transform from a rotator and a location.
 * @topic Unreal
 */
/**
 * @function DefaultIsIdentity
 * @summary Construct a transform from a rotator and a location.
 * @covers FTransform.Construction
 * @inputs none
 * @return the transform for a ninety degree yaw at (50, 100, 150)
 */
eturn FTransform(Rot, FVector(50, 100, 150));
}

/**
 * Observe that the default constructor yields the identity transform.
 *
 * @Kind Observe
 * @Covers FTransform.Construction
 * @Inputs none
 * @Return true when the default equals the identity constant
 */
UFUNCTION()
bool DefaultIsIdentity()
{
	return ConstructDefault().Equals(FTransform::Identity, 0.001);
}
/** @end */
/**
 * @begin transform-interpolation
 * @summary Observe that the mid-point blend matches the native Blend.
 * @topic Unreal
 */
/**
 * @function BlendTransformsNominal
 * @summary Observe that the mid-point blend matches the native Blend.
 * @covers FTransform.Interpolation
 * @inputs none
 * @return true when BlendTransforms equals the native Blend at 0.5
 */
bool BlendTransformsNominal()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	FTransform Expected;
	Expected.Blend(A, B, 0.5f);
	return BlendTransforms().Equals(Expected, 0.01);
}
/** @end */
/**
 * @begin transform-inverse
 * @summary Observe that GetInverse matches the native inverse.
 * @topic Unreal
 */
/**
 * @function GetInverseNominal
 * @summary Observe that GetInverse matches the native inverse.
 * @covers FTransform.Inverse
 * @inputs none
 * @return true when GetInverse equals T.Inverse()
 */
bool GetInverseNominal()
{
	FTransform T = FTransform(FVector(100, 200, 300));
	return GetInverse().Equals(T.Inverse(), 0.001);
}
/** @end */
/**
 * @begin transform-member-access
 * @summary Write a yaw-90 rotation onto the identity.
 * @topic Unreal
 */
/**
 * @function GetLocationNominal
 * @summary Write a yaw-90 rotation onto the identity.
 * @covers FTransform.MemberAccess
 * @inputs none
 * @return identity with a ninety degree yaw
 */
 GetLocation equals (100, 200, 300)
 */
UFUNCTION()
bool GetLocationNominal()
{
	return GetLocation() == FVector(100, 200, 300);
}
/** @end */
/**
 * @begin transform-position-and-vector
 * @summary Observe that TransformPosition matches the native conversion.
 * @topic Unreal
 */
/**
 * @function TransformPositionNominal
 * @summary Observe that TransformPosition matches the native conversion.
 * @covers FTransform.PositionAndVector
 * @inputs none
 * @return true when the result equals the native TransformPosition
 */
bool TransformPositionNominal()
{
	FTransform T = FTransform(FVector(100, 0, 0));
	return TransformPosition().Equals(T.TransformPosition(FVector(10, 0, 0)), 0.001);
}
/** @end */
/**
 * @begin container-properties
 * @summary WorldStory: BeginPlay fills the array and the map with three transforms each, one per axis.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay fills the array and the map with three transforms each, one per axis.
 * @covers FTransform.ContainerProperties
 * @inputs none
 * @return three entries in each container
 */
UCLASS()
class ACoverageFTransformContainerActor : AActor
{
	UPROPERTY()
	TArray<FTransform> TransformArray;

	UPROPERTY()
	TMap<int, FTransform> IntToTransformMap;

	/**
	 * WorldStory: BeginPlay fills the array and the map with three transforms each, one per
	 * axis.
	 *
	 * @Kind WorldStory
	 * @Covers FTransform.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		TransformArray.Add(FTransform(FVector(100, 0, 0)));
		TransformArray.Add(FTransform(FVector(0, 200, 0)));
		TransformArray.Add(FTransform(FVector(0, 0, 300)));

		IntToTransformMap.Add(1, FTransform(FVector(10, 0, 0)));
		IntToTransformMap.Add(2, FTransform(FVector(0, 20, 0)));
		IntToTransformMap.Add(3, FTransform(FVector(0, 0, 30)));
	}
/** @end */
/**
 * @begin declaration-defaults
 * @summary Observe that the identity-declared property reads as the identity transform.
 * @topic Unreal
 */
/**
 * @function IdentityTransformSpawned
 * @summary Observe that the identity-declared property reads as the identity transform.
 * @covers FTransform.DeclarationDefaults
 * @inputs none
 * @return true when the translation is the origin and the scale is all ones
 */
UCLASS()
class ACoverageFTransformDefaultsActor : AActor
{
	UPROPERTY()
	FTransform IdentityTransform = FTransform::Identity;

	UPROPERTY()
	FTransform CustomTransform = FTransform(FVector(100, 200, 300));

	UPROPERTY()
	FTransform NoDefaultTransform;

	UPROPERTY()
	FTransform FullTransform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));

	bool IdentityTransformSpawned()
	{
		if (IdentityTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetLocation().Z != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetScale3D().X != 1.0)
		{
			return false;
		}
		if (IdentityTransform.GetScale3D().Y != 1.0)
		{
			return false;
		}
		return IdentityTransform.GetScale3D().Z == 1.0;
	}
/** @end */
/**
 * @begin member-access
 * @summary SetLocation and SetScale3D writing a FTransform UPROPERTY during BeginPlay.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary SetLocation and SetScale3D writing a FTransform UPROPERTY during BeginPlay.
 * @covers FTransform.member-access
 * @inputs FTransform values for this case
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoverageFTransformMemberActor : AActor
{
	UPROPERTY()
	FTransform MyTransform;

	/**
	 * WorldStory: BeginPlay writes the translation and the scale onto the property.
	 *
	 * @Kind WorldStory
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return the translation

 set to (100, 200, 300) and the scale to (5, 5, 5)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MyTransform.SetLocation(FVector(100, 200, 300));
		MyTransform.SetScale3D(FVector(5, 5, 5));
	}
/** @end */
/**
 * @begin write-round-trip
 * @summary Observe that an untouched property is the identity transform.
 * @topic Unreal
 */
/**
 * @function DefaultEmpty
 * @summary Observe that an untouched property is the identity transform.
 * @covers FTransform.WriteRoundTrip
 * @inputs none
 * @return true when the translation is the origin and the scale is one
 */
UCLASS()
class ACoverageFTransformWriteActor : AActor
{
	UPROPERTY()
	FTransform TransformValue;

	bool DefaultEmpty()
	{
		if (TransformValue.GetLocation().X != 0.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Z != 0.0)
		{
			return false;
		}
		return TransformValue.GetScale3D().X == 1.0;
	}
/** @end */
/**
 * @begin function-default-parameters
 * @summary A defaulted transform parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Compose two transforms, where the second defaults to the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform and an optional second transform
	 * @Return the product of the two
	 * @Param a the first transform
	 * @Param b the second transform, defaulting to identity
	 */
	UFUNCTION()
	FTransform ComposeWithDefault(FTransform a, FTransform b = FTransform::Identity)
	{
		return a * b;
	}

	/**
	 * Compose a transform relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform
	 * @Return the transform composed with identity
	 * @Param a the transform to compose
	 */
	UFUNCTION()
	FTransform ComposeUsingDefault(FTransform a)
	{
		return ComposeWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the product equals A * B
	 */
	UFUNCTION()
	bool ComposeWithDefaultExplicit()
	{
		FTransform Arg1 = FTransform(FVector(100, 0, 0));
		FTransform Arg2 = FTransform(FVector(0, 100, 0));
		FTransform Expected = Arg1 * Arg2;
		return ComposeWithDefault(Arg1, Arg2).Equals(Expected, 0.01);
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the product equals A * Identity
	 */
	UFUNCTION()
	bool ComposeUsingDefaultNominal()
	{
		FTransform Arg1 = FTransform(FVector(100, 200, 300));
		FTransform Expected = Arg1 * FTransform::Identity;
		return ComposeUsingDefault(Arg1).Equals(Expected, 0.01);
	}

	/**
	 * Observe that composing an identity with the default stays at identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a default-constructed transform
	 * @Return true when the product is identity with a zero location
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ComposeUsingDefaultIdentityEmpty()
	{
		FTransform Empty = FTransform::Identity;

		if (!ComposeUsingDefault(Empty).Equals(FTransform::Identity, 0.01))
		{
			return false;
		}
		return ComposeUsingDefault(Empty).GetLocation().Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that mutating the returned product leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform and the mutated product built from it
	 * @Return true when the argument still reads (100, 200, 300)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ComposeUsingDefaultCopyIndependence()
	{
		FTransform Arg1 = FTransform(FVector(100, 200, 300));
		FTransform Result = ComposeUsingDefault(Arg1);
		Result.SetLocation(FVector::ZeroVector);
		return Arg1.GetLocation().Equals(FVector(100, 200, 300), 0.01);
	}
}
/** @end */
/**
 * @begin function-parameters-in
 * @summary A FTransform passed by read-only reference, where the callee reads the translation without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is kept.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Read the translation of a transform passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a transform
	 * @Return the translation of the transform
	 * @Param t the transform to read
	 */
	UFUNCTION()
	FVector AcceptTransformIn(FTransform&in t)
	{
		return t.GetLocation();
	}

	/**
	 * Observe that the measured translation matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the translation is (50, 100, 150)
	 */
	UFUNCTION()
	bool AcceptTransformInNominal()
	{
		FTransform Input = FTransform(FVector(50, 100, 150));
		return AcceptTransformIn(Input).Equals(FVector(50, 100, 150), 0.01);
	}

	/**
	 * Observe that an empty argument reads as the origin.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a default-constructed transform
	 * @Return true when the translation is the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptTransformInDefaultEmpty()
	{
		FTransform Empty = FTransform();
		return AcceptTransformIn(Empty).Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that reading through the reference leaves the caller's transform alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a transform read through the reference
	 * @Return true when the argument still reads (50, 100, 150)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTransformInCopyIndependence()
	{
		FTransform Input = FTransform(FVector(50, 100, 150));
		FVector Result = AcceptTransformIn(Input);
		Result.X = 0.0;
		return Input.GetLocation().Equals(FVector(50, 100, 150), 0.01);
	}
}
/** @end */
/**
 * @begin function-parameters-in-out
 * @summary A FTransform passed by mutable reference and rewritten or mutated in place. C++ executes each entrypoint and checks the value written back, so those names are part of the contract and are kept verbatim. The observers.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Replace a transform through a mutable reference, keeping rotation and location and
	 * writing a uniform scale of two.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs a transform
	 * @Return the transform reassigned with scale (2, 2, 2)
	 * @Param t the transform to replace
	 */
	UFUNCTION()
	void AssignScaleTransform(FTransform&inout t)
	{
		t = FTransform(t.GetRotation(), t.GetLocation(), FVector(2, 2, 2));
	}

	/**
	 * Replace a transform through a mutable reference, adding an offset to its translation.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs a transform and an offset
	 * @Return the transform reassigned with the offset added to its location
	 * @Param t the transform to replace
	 * @Param offset the translation to add
	 */
	UFUNCTION()
	void AssignTranslateTransform(FTransform&inout t, FVector offset)
	{
		t = FTransform(t.GetRotation(), t.GetLocation() + offset, t.GetScale3D());
	}

	/**
	 * Write the scale in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs a transform
	 * @Return the transform with scale set to (2, 2, 2)
	 * @Param t the transform to mutate
	 */
	UFUNCTION()
	void MutateScaleTransform(FTransform&inout t)
	{
		t.SetScale3D(FVector(2, 2, 2));
	}

	/**
	 * Observe that the caller's transform is reassigned with a uniform scale of two.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the scale reads (2, 2, 2)
	 */
	UFUNCTION()
	bool AssignScaleTransformNominal()
	{
		FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
		AssignScaleTransform(Value);
		return Value.GetScale3D().Equals(FVector(2, 2, 2), 0.01);
	}

	/**
	 * Observe that the caller's translation is offset in place.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the location reads (15, 30, 45)
	 */
	UFUNCTION()
	bool AssignTranslateTransformNominal()
	{
		FTransform Value = FTransform(FVector(10, 20, 30));
		FVector Offset = FVector(5, 10, 15);
		AssignTranslateTransform(Value, Offset);
		return Value.GetLocation().Equals(FVector(15, 30, 45), 0.01);
	}

	/**
	 * Observe that SetScale3D writes through the mutable reference.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the scale reads (2, 2, 2)
	 */
	UFUNCTION()
	bool MutateScaleTransformNominal()
	{
		FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
		MutateScaleTransform(Value);
		return Value.GetScale3D().Equals(FVector(2, 2, 2), 0.01);
	}

	/**
	 * Observe that an identity scale remains (1, 1, 1) until it is mutated.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs a default-scale transform
	 * @Return true when the scale is (1, 1, 1) and the location is zero
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AssignScaleTransformDefaultEmpty()
	{
		FTransform Value = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));

		if (!Value.GetScale3D().Equals(FVector(1, 1, 1), 0.01))
		{
			return false;
		}
		return Value.GetLocation().Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that translating in place leaves the offset argument untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersInOut
	 * @Inputs a transform and an offset
	 * @Return true when the offset still reads (5, 10, 15) and the location is (15, 30, 45)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AssignTranslateTransformCopyIndependence()
	{
		FTransform Value = FTransform(FVector(10, 20, 30));
		FVector Offset = FVector(5, 10, 15);
		AssignTranslateTransform(Value, Offset);

		if (!Offset.Equals(FVector(5, 10, 15), 0.01))
		{
			return false;
		}
		return Value.GetLocation().Equals(FVector(15, 30, 45), 0.01);
	}
}
/** @end */
/**
 * @begin function-parameters-out
 * @summary FTransforms written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Write a fixed transform into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FTransform(FVector(100, 200, 300))
	 * @Param t the transform to write into
	 */
	UFUNCTION()
	void WriteTransform(FTransform&out t)
	{
		t = FTransform(FVector(100, 200, 300));
	}

	/**
	 * Write two translations into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as (10, 0, 0), the second as (0, 20, 0)
	 * @Param a the first transform to write into
	 * @Param b the second transform to write into
	 */
	UFUNCTION()
	void WriteMultipleTransforms(FTransform&out a, FTransform&out b)
	{
		a = FTransform(FVector(10, 0, 0));
		b = FTransform(FVector(0, 20, 0));
	}

	/**
	 * Observe that the single out parameter receives the written translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value reads (100, 200, 300)
	 */
	UFUNCTION()
	bool WriteTransformNominal()
	{
		FTransform OutValue;
		WriteTransform(OutValue);
		return OutValue.GetLocation().Equals(FVector(100, 200, 300), 0.01);
	}

	/**
	 * Observe that both out parameters receive their own translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads (10, 0, 0) and the second (0, 20, 0)
	 */
	UFUNCTION()
	bool WriteMultipleTransformsNominal()
	{
		FTransform OutA;
		FTransform OutB;
		WriteMultipleTransforms(OutA, OutB);

		if (!OutA.GetLocation().Equals(FVector(10, 0, 0), 0.01))
		{
			return false;
		}
		return OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when the translation is the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteTransformDefaultEmpty()
	{
		FTransform OutValue;
		return OutValue.GetLocation().Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads (0, 20, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleTransformsCopyIndependence()
	{
		FTransform OutA;
		FTransform OutB;
		WriteMultipleTransforms(OutA, OutB);
		OutA.SetLocation(FVector::ZeroVector);
		return OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
	}
}
/** @end */
/**
 * @begin function-parameters-value
 * @summary FTransforms passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Add a fixed translation to a transform passed by value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a transform
	 * @Return the transform with (100, 0, 0) added to its translation
	 * @Param t the transform to offset
	 */
	UFUNCTION()
	FTransform AcceptTransform(FTransform t)
	{
		FTransform Modified = t;
		Modified.AddToTranslation(FVector(100, 0, 0));
		return Modified;
	}

	/**
	 * Measure the world-space gap between two transforms passed by value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs two transforms
	 * @Return the difference of their transformed origins
	 * @Param a the first transform
	 * @Param b the second transform
	 */
	UFUNCTION()
	FVector AcceptTwoTransforms(FTransform a, FTransform b)
	{
		FVector PosA = a.TransformPosition(FVector::ZeroVector);
		FVector PosB = b.TransformPosition(FVector::ZeroVector);
		return PosB - PosA;
	}

	/**
	 * Observe that the offset matches the expected translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result location is (110, 20, 30)
	 */
	UFUNCTION()
	bool AcceptTransformNominal()
	{
		FTransform Input = FTransform(FVector(10, 20, 30));
		return AcceptTransform(Input).GetLocation().Equals(FVector(110, 20, 30), 0.01);
	}

	/**
	 * Observe that the gap between two origins matches the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the gap is (300, 0, 0)
	 */
	UFUNCTION()
	bool AcceptTwoTransformsNominal()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(400, 0, 0));
		return AcceptTwoTransforms(A, B).Equals(FVector(300, 0, 0), 0.01);
	}

	/**
	 * Observe that offsetting an identity yields a translation of (100, 0, 0).
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a default-constructed transform
	 * @Return true when the result location is (100, 0, 0)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptTransformDefaultIdentity()
	{
		return AcceptTransform(FTransform()).GetLocation().Equals(FVector(100, 0, 0), 0.01);
	}

	/**
	 * Observe that mutating the returned transform leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a transform and the mutated result of passing it in
	 * @Return true when the argument still reads (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTransformCopyIndependence()
	{
		FTransform Input = FTransform(FVector(10, 20, 30));
		FTransform Result = AcceptTransform(Input);
		Result.SetLocation(FVector::ZeroVector);
		return Input.GetLocation().Equals(FVector(10, 20, 30), 0.01);
	}
}
/** @end */
/**
 * @begin function-return-values
 * @summary Transforms returned from functions: the identity constant, a literal translation, a computed product and an inverse. C++ executes each entrypoint and compares the result with the native equivalent, so those names are.
 * @topic Unreal
 */
namespace FTransformTest
{
	/**
	 * Return the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return FTransform::Identity
	 */
	UFUNCTION()
	FTransform ReturnIdentity()
	{
		return FTransform::Identity;
	}

	/**
	 * Return a literal translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return FTransform(FVector(50, 100, 150))
	 */
	UFUNCTION()
	FTransform ReturnCustomTransform()
	{
		return FTransform(FVector(50, 100, 150));
	}

	/**
	 * Return a product of two translations.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return A * B for (100, 0, 0) and (0, 100, 0)
	 */
	UFUNCTION()
	FTransform ReturnComputedTransform()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(0, 100, 0));
		return A * B;
	}

	/**
	 * Return the inverse of a known translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return the inverse of FTransform(FVector(10, 20, 30))
	 */
	UFUNCTION()
	FTransform ReturnInverse()
	{
		FTransform T = FTransform(FVector(10, 20, 30));
		return T.Inverse();
	}

	/**
	 * Observe that the identity return matches the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals identity
	 */
	UFUNCTION()
	bool ReturnIdentityNominal()
	{
		return ReturnIdentity().Equals(FTransform::Identity, 0.01);
	}

	/**
	 * Observe that the literal return keeps its translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the location is (50, 100, 150)
	 */
	UFUNCTION()
	bool ReturnCustomTransformNominal()
	{
		return ReturnCustomTransform().GetLocation().Equals(FVector(50, 100, 150), 0.01);
	}

	/**
	 * Observe that the computed return matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals A * B
	 */
	UFUNCTION()
	bool ReturnComputedTransformNominal()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(0, 100, 0));
		FTransform Expected = A * B;
		return ReturnComputedTransform().Equals(Expected, 0.01);
	}

	/**
	 * Observe that the inverse return matches the native inverse.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals Inverse of (10, 20, 30)
	 */
	UFUNCTION()
	bool ReturnInverseNominal()
	{
		FTransform T = FTransform(FVector(10, 20, 30));
		FTransform Expected = T.Inverse();
		return ReturnInverse().Equals(Expected, 0.01);
	}

	/**
	 * Observe that a default transform equals the identity return.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs a default-constructed transform
	 * @Return true when it equals identity and the identity return
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnIdentityDefaultEmpty()
	{
		FTransform Empty = FTransform();

		if (!Empty.Equals(FTransform::Identity, 0.01))
		{
			return false;
		}
		return ReturnIdentity().Equals(Empty, 0.01);
	}

	/**
	 * Observe that mutating a copy leaves the returned transform untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs the returned transform and a mutated copy of it
	 * @Return true when the original still reads (50, 100, 150) and the copy is zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomTransformCopyIndependence()
	{
		FTransform Original = ReturnCustomTransform();
		FTransform Copy = Original;
		Copy.SetLocation(FVector::ZeroVector);

		if (!Original.GetLocation().Equals(FVector(50, 100, 150), 0.01))
		{
			return false;
		}
		return Copy.GetLocation().Equals(FVector::ZeroVector, 0.01);
	}
}
/** @end */
