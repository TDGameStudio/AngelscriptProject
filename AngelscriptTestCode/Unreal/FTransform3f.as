/**
 * @version v1
 * @summary FTransform3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FTransform3f
 *
 * world-axes-plus-translation
 * ftransform3f-constructors-copy-translation
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
 * remove-scaling
 * set-to-relative-transform
 * set-location
 * set-translation
 * add-to-translation
 * set-rotation
 * set-scale-3-d
 * set-translation-and-scale-3-d
 * container-api
 * ftransform3f-identity-zero-translation
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
 */
/**
 * @begin world-axes-plus-translation
 * @summary world axes plus translation, FTransform conversion,
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary world axes plus translation, FTransform conversion,
 * @covers FTransform3f.world-axes-plus-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform conversion,

 Inverse of (10,0,0),
// blend translations 0 and 10 at alpha 0/0.5/1.
// Expected observations: Declaration and default construction equal Identity.
// Copy is independent. Conversion constructors store the supplied parts.
// Inverse of +10 X is -10 X. Blend alpha 0/1 selects endpoints; 0.5 is
// midpoint.
// Boundary/ownership: Inverse returns a new transform. Blend mutates the
// receiver and does not mutate the source atoms.
// FTransform3f Value; default construction equals Identity. No fixture.
bool ObserveSurface001Nominal()
{
	FTransform3f Value;
	return Value.Equals(FTransform3f::Identity);
}
/** @end */
/**
 * @begin ftransform3f-constructors-copy-translation
 * @summary FTransform3f constructors: copy, translation, quat, rotator, axes, FTransform conversion.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary FTransform3f constructors: copy, translation, quat, rotator, axes, FTransform conversion.
 * @covers FTransform3f.ftransform3f-constructors-copy-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform conversion,

bool ObserveValueNominal()
{
	FTransform3f DefaultValue;
	FTransform3f Copied(FTransform3f(FVector3f(1.0, 2.0, 3.0)));
	FTransform3f FromTranslation(FVector3f(1.0, 2.0, 3.0));
	FTransform3f FromQuat(FQuat4f::Identity);
	FTransform3f FromRotator(FRotator3f(0.0, 90.0, 0.0));
	FTransform3f FromAxes(FVector3f::ForwardVector, FVector3f::RightVector, FVector3f::UpVector, FVector3f(4.0, 5.0, 6.0));
	FTransform DoublePrecision(FVector(7.0, 8.0, 9.0));
	FTransform3f FromDouble(DoublePrecision);
	FTransform3f Original = Copied;
	Copied.SetTranslation(FVector3f::ZeroVector);
	return DefaultValue.Equals(FTransform3f::Identity) &&
		Original.GetTranslation().X == 1.0 &&
		FromTranslation.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
		FromQuat.GetRotation().Equals(FQuat4f::Identity) &&
		FromRotator.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0)) &&
		FromAxes.GetTranslation().Equals(FVector3f(4.0, 5.0, 6.0)) &&
		FromAxes.GetRotation().Equals(FQuat4f::Identity) &&
		FromDouble.GetTranslation().Equals(FVector3f(7.0, 8.0, 9.0));
}
/** @end */
/**
 * @begin inverse
 * @summary Inverse of translation +10 X is -10 X; Identity inverse stays Identity.
 * @topic Unreal
 */
/**
 * @function ObserveInverseNominal
 * @summary Inverse of translation +10 X is -10 X; Identity inverse stays Identity.
 * @covers FTransform3f.inverse
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform conversion,

bool ObserveInverseNominal()
{
	FTransform3f Moved(FVector3f(10.0, 0.0, 0.0));
	FTransform3f Inverse = Moved.Inverse();
	FTransform3f IdentityInverse = FTransform3f::Identity.Inverse();
	return Inverse.GetTranslation().Equals(FVector3f(-10.0, 0.0, 0.0)) &&
		IdentityInverse.Equals(FTransform3f::Identity) &&
		Moved.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin blend
 * @summary Blend mutates the receiver: alpha 0/1 are endpoints, 0.5 is midpoint.
 * @topic Unreal
 */
/**
 * @function ObserveBlendNominal
 * @summary Blend mutates the receiver: alpha 0/1 are endpoints, 0.5 is midpoint.
 * @covers FTransform3f.blend
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// world axes plus translation, FTransform conversion,

bool ObserveBlendNominal()
{
	FTransform3f Atom1(FVector3f::ZeroVector);
	FTransform3f Atom2(FVector3f(10.0, 0.0, 0.0));
	FTransform3f Blended;
	Blended.Blend(Atom1, Atom2, 0.0);
	bool bAlpha0 = Blended.GetTranslation().IsNearlyZero();
	Blended.Blend(Atom1, Atom2, 1.0);
	bool bAlpha1 = Blended.GetTranslation().Equals(FVector3f(10.0, 0.0, 0.0));
	Blended.Blend(Atom1, Atom2, 0.5);
	bool bAlphaHalf = Blended.GetTranslation().Equals(FVector3f(5.0, 0.0, 0.0));
	return bAlpha0 && bAlpha1 && bAlphaHalf && Atom2.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin blend-with
 * @summary yaw 90, Identity,
 * @topic Unreal
 */
/**
 * @function ObserveBlendWithNominal
 * @summary yaw 90, Identity,
 * @covers FTransform3f.blend-with
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

 and local (1,0,0).
// Expected observations: BlendWith alpha 0 keeps the receiver; 1 replaces it.
// Per-axis ScaleTranslation yields (2,2,3). Accumulate writes translation and
// scale. Identity TransformPosition preserves. Scale 2 scales positions but
// NoScale does not. Inverse of +10 X maps 11 back to 1. Yaw 90 maps X to Y.
// Boundary/ownership: BlendWith, ScaleTranslation, and Accumulate mutate the
// receiver. Transform* helpers return new vectors.
bool ObserveBlendWithNominal()
{
	FTransform3f Current(FVector3f::ZeroVector);
	FTransform3f Other(FVector3f(10.0, 0.0, 0.0));
	Current.BlendWith(Other, 0.0);
	bool bKept = Current.GetTranslation().IsNearlyZero();
	Current.BlendWith(Other, 1.0);
	return bKept && Current.GetTranslation().Equals(FVector3f(10.0, 0.0, 0.0)) && Other.GetTranslation().X == 10.0;
}
/** @end */
/**
 * @begin scale-translation
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveScaleTranslationNominal
 * @summary receiver.
 * @covers FTransform3f.scale-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveScaleTranslationNominal()
{
	FTransform3f PerAxis(FVector3f(1.0, 2.0, 3.0));
	PerAxis.ScaleTranslation(FVector3f(2.0, 1.0, 1.0));
	FTransform3f Uniform(FVector3f(1.0, 2.0, 3.0));
	Uniform.ScaleTranslation(2.0);
	return PerAxis.GetTranslation().Equals(FVector3f(2.0, 2.0, 3.0)) &&
		Uniform.GetTranslation().Equals(FVector3f(2.0, 4.0, 6.0)) &&
		PerAxis.GetScale3D().Equals(FVector3f::OneVector);
}
/** @end */
/**
 * @begin accumulate
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveAccumulateNominal
 * @summary receiver.
 * @covers FTransform3f.accumulate
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveAccumulateNominal()
{
	FTransform3f Base = FTransform3f::Identity;
	FTransform3f Delta(FQuat4f::Identity, FVector3f(1.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
	Base.Accumulate(Delta);
	return Base.GetTranslation().Equals(FVector3f(1.0, 0.0, 0.0)) &&
		Base.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
		Delta.GetTranslation().X == 1.0;
}
/** @end */
/**
 * @begin transform-position
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTransformPositionNominal
 * @summary receiver.
 * @covers FTransform3f.transform-position
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveTransformPositionNominal()
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
/** @end */
/**
 * @begin transform-position-no-scale
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTransformPositionNoScaleNominal
 * @summary receiver.
 * @covers FTransform3f.transform-position-no-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveTransformPositionNoScaleNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
	FVector3f WithoutScale = Scaled.TransformPositionNoScale(FVector3f(1.0, 0.0, 0.0));
	return WithoutScale.Equals(FVector3f(11.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin inverse-transform-position
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformPositionNominal
 * @summary receiver.
 * @covers FTransform3f.inverse-transform-position
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveInverseTransformPositionNominal()
{
	FTransform3f Moved(FVector3f(10.0, 0.0, 0.0));
	FVector3f Local = Moved.InverseTransformPosition(FVector3f(11.0, 0.0, 0.0));
	FVector3f IdentityLocal = FTransform3f::Identity.InverseTransformPosition(FVector3f(1.0, 2.0, 3.0));
	return Local.Equals(FVector3f(1.0, 0.0, 0.0)) && IdentityLocal.Equals(FVector3f(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin inverse-transform-position-no-scale
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformPositionNoScaleNominal
 * @summary receiver.
 * @covers FTransform3f.inverse-transform-position-no-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveInverseTransformPositionNoScaleNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
	FVector3f Local = Scaled.InverseTransformPositionNoScale(FVector3f(11.0, 0.0, 0.0));
	return Local.Equals(FVector3f(1.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin transform-vector
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTransformVectorNominal
 * @summary receiver.
 * @covers FTransform3f.transform-vector
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveTransformVectorNominal()
{
	FVector3f Translated = FTransform3f(FVector3f(10.0, 0.0, 0.0)).TransformVector(FVector3f::ForwardVector);
	FVector3f Scaled = FTransform3f(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0)).TransformVector(FVector3f::ForwardVector);
	FVector3f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformVector(FVector3f::ForwardVector);
	return Translated.Equals(FVector3f::ForwardVector) &&
		Scaled.Equals(FVector3f(2.0, 0.0, 0.0)) &&
		Rotated.Equals(FVector3f::RightVector);
}
/** @end */
/**
 * @begin transform-vector-no-scale
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveTransformVectorNoScaleNominal
 * @summary receiver.
 * @covers FTransform3f.transform-vector-no-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// yaw 90, Identity,

bool ObserveTransformVectorNoScaleNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(10.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
	FVector3f WithoutScale = Scaled.TransformVectorNoScale(FVector3f::ForwardVector);
	FVector3f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformVectorNoScale(FVector3f::ForwardVector);
	return WithoutScale.Equals(FVector3f::ForwardVector) && Rotated.Equals(FVector3f::RightVector);
}
/** @end */
/**
 * @begin inverse-transform-vector
 * @summary Equals ignores scale.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformVectorNominal
 * @summary Equals ignores scale.
 * @covers FTransform3f.inverse-transform-vector
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

 90 is (0,90,0). ConcatenateRotation of
// yaw 90 writes that yaw. InitFromString succeeds on formatter text and fails
// on empty.
// Boundary/ownership: NormalizeRotation and ConcatenateRotation mutate the
// receiver. InitFromString mutates and reports success.
bool ObserveInverseTransformVectorNominal()
{
	FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
	FVector3f Local = Yaw90.InverseTransformVector(FVector3f::RightVector);
	FVector3f Scaled = FTransform3f(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0)).InverseTransformVector(FVector3f(2.0, 0.0, 0.0));
	return Local.Equals(FVector3f::ForwardVector) && Scaled.Equals(FVector3f::ForwardVector);
}
/** @end */
/**
 * @begin inverse-transform-vector-no-scale
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInverseTransformVectorNoScaleNominal
 * @summary receiver.
 * @covers FTransform3f.inverse-transform-vector-no-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveInverseTransformVectorNoScaleNominal()
{
	FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
	FVector3f Local = Yaw90.InverseTransformVectorNoScale(FVector3f::RightVector);
	FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 2.0, 2.0));
	FVector3f Unscaled = Scaled.InverseTransformVectorNoScale(FVector3f(2.0, 0.0, 0.0));
	return Local.Equals(FVector3f::ForwardVector) && Unscaled.Equals(FVector3f(2.0, 0.0, 0.0));
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
 * @covers FTransform3f.transform-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveTransformRotationNominal()
{
	FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Preserved = FTransform3f::Identity.TransformRotation(Yaw90);
	FQuat4f Rotated = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).TransformRotation(FQuat4f::Identity);
	return Preserved.Equals(Yaw90) && !Rotated.Equals(FQuat4f::Identity);
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
 * @covers FTransform3f.inverse-transform-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveInverseTransformRotationNominal()
{
	FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Preserved = FTransform3f::Identity.InverseTransformRotation(Yaw90);
	FQuat4f Local = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).InverseTransformRotation(Yaw90);
	return Preserved.Equals(Yaw90) && Local.Equals(FQuat4f::Identity);
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
 * @covers FTransform3f.subtract-translations
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveSubtractTranslationsNominal()
{
	FTransform3f Left(FVector3f(5.0, 0.0, 0.0));
	FTransform3f Right(FVector3f(2.0, 0.0, 0.0));
	FVector3f Difference = Left.SubtractTranslations(Right);
	FVector3f VsIdentity = Left.SubtractTranslations(FTransform3f::Identity);
	return Difference.Equals(FVector3f(3.0, 0.0, 0.0)) && VsIdentity.Equals(FVector3f(5.0, 0.0, 0.0));
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
 * @covers FTransform3f.normalize-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveNormalizeRotationNominal()
{
	FTransform3f Identity = FTransform3f::Identity;
	Identity.NormalizeRotation();
	FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
	Yaw90.NormalizeRotation();
	return Identity.IsRotationNormalized() &&
		Yaw90.IsRotationNormalized() &&
		Yaw90.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
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
 * @covers FTransform3f.translation-equals
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveTranslationEqualsNominal()
{
	FTransform3f Base(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	FTransform3f Moved(FVector3f(9.0, 0.0, 0.0));
	return Base.TranslationEquals(Scaled) &&
		Base.TranslationEquals(Scaled, __KINDA_SMALL_NUMBER_flt) &&
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
 * @covers FTransform3f.rotator
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveRotatorNominal()
{
	FRotator3f IdentityRot = FTransform3f::Identity.Rotator();
	FRotator3f Yaw90 = FTransform3f(FRotator3f(0.0, 90.0, 0.0)).Rotator();
	return IdentityRot.Equals(FRotator3f::ZeroRotator) && Yaw90.Equals(FRotator3f(0.0, 90.0, 0.0));
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
 * @covers FTransform3f.concatenate-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveConcatenateRotationNominal()
{
	FTransform3f Transform = FTransform3f::Identity;
	Transform.ConcatenateRotation(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
	return Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
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
 * @covers FTransform3f.init-from-string
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Equals ignores scale. Rotator of yaw

bool ObserveInitFromStringNominal()
{
	FTransform3f Source(FRotator3f(0.0, 90.0, 0.0), FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
	FString Text = f"{Source}";
	FTransform3f Parsed;
	bool bValid = Parsed.InitFromString(Text);
	FTransform3f Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bValid && Parsed.Equals(Source) && !bEmptyFailed;
}
/** @end */
/**
 * @begin assignment
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Observe the container API.
 * @covers FTransform3f.assignment
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Translation (1,0,0) and (2,0,0), Identity, yaw-90 quat, and a copied
// original.
// Expected observations: Assignment copies translation. Two translations
// compose to X=3. Identity * yaw-90 has yaw 90. *= mutates. Original copy
// stays X=1.
// Boundary/ownership: * returns a new transform. *= mutates the left operand.
bool ObserveAssignmentNominal()
{
	FTransform3f Transform;
	FTransform3f Other(FVector3f(1.0, 0.0, 0.0));
	FTransform3f Original = Other;
	Transform = Other;
	FTransform3f Combined = Transform * FTransform3f(FVector3f(2.0, 0.0, 0.0));
	FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FTransform3f Rotated = FTransform3f::Identity * Yaw90;
	Other.SetTranslation(FVector3f(9.0, 0.0, 0.0));
	return Transform.GetTranslation().X == 1.0 &&
		Combined.GetTranslation().X == 3.0 &&
		Rotated.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0)) &&
		Original.GetTranslation().X == 1.0;
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
 * @covers FTransform3f.multiply-assign
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveMultiplyAssignNominal()
{
	FTransform3f Transform(FVector3f(1.0, 0.0, 0.0));
	Transform *= FTransform3f(FVector3f(2.0, 0.0, 0.0));
	FTransform3f Rotated = FTransform3f::Identity;
	Rotated *= FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	return Transform.GetTranslation().X == 3.0 && Rotated.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
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
 * @covers FTransform3f.remove-scaling
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Scale (2,2,2), child 13 vs parent 10, location (1,2,3), add (1,0,0),
// yaw-90 quat, default __SMALL_NUMBER_flt, and a repeated SetLocation.
// Expected observations: RemoveScaling restores unit scale. Relative rewrite
// yields X=3. SetLocation/SetTranslation write GetLocation. AddToTranslation
// adds. SetRotation yields yaw 90. SetScale3D stores (2,3,4). Combined setter
// keeps rotation.
// Boundary/ownership: All listed methods mutate the receiver. RemoveScaling
// default tolerance is __SMALL_NUMBER_flt.
bool ObserveRemoveScalingNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 0.0, 0.0), FVector3f(2.0, 2.0, 2.0));
	Scaled.RemoveScaling();
	FTransform3f Explicit(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(3.0, 3.0, 3.0));
	Explicit.RemoveScaling(__SMALL_NUMBER_flt);
	return Scaled.GetScale3D().Equals(FVector3f::OneVector) &&
		Explicit.GetScale3D().Equals(FVector3f::OneVector) &&
		Scaled.GetTranslation().X == 1.0;
}
/** @end */
/**
 * @begin set-to-relative-transform
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetToRelativeTransformNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-to-relative-transform
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetToRelativeTransformNominal()
{
	FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
	FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
	Child.SetToRelativeTransform(Parent);
	return Child.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0));
}
/** @end */
/**
 * @begin set-location
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetLocationNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-location
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetLocationNominal()
{
	FTransform3f Transform = FTransform3f::Identity;
	Transform.SetLocation(FVector3f(1.0, 2.0, 3.0));
	Transform.SetLocation(FVector3f(4.0, 5.0, 6.0));
	return Transform.GetLocation().Equals(FVector3f(4.0, 5.0, 6.0));
}
/** @end */
/**
 * @begin set-translation
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetTranslationNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetTranslationNominal()
{
	FTransform3f Transform = FTransform3f::Identity;
	Transform.SetTranslation(FVector3f(1.0, 2.0, 3.0));
	return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin add-to-translation
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveAddToTranslationNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.add-to-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAddToTranslationNominal()
{
	FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
	Transform.AddToTranslation(FVector3f(1.0, 0.0, 0.0));
	Transform.AddToTranslation(FVector3f::ZeroVector);
	return Transform.GetTranslation().Equals(FVector3f(2.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin set-rotation
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetRotationNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetRotationNominal()
{
	FTransform3f Transform = FTransform3f::Identity;
	Transform.SetRotation(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
	return Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin set-scale-3-d
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetScale3DNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-scale-3-d
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetScale3DNominal()
{
	FTransform3f Transform = FTransform3f::Identity;
	Transform.SetScale3D(FVector3f(2.0, 3.0, 4.0));
	return Transform.GetScale3D().Equals(FVector3f(2.0, 3.0, 4.0));
}
/** @end */
/**
 * @begin set-translation-and-scale-3-d
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSetTranslationAndScale3DNominal
 * @summary default tolerance is __SMALL_NUMBER_flt.
 * @covers FTransform3f.set-translation-and-scale-3-d
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSetTranslationAndScale3DNominal()
{
	FTransform3f Transform(FRotator3f(0.0, 90.0, 0.0));
	Transform.SetTranslationAndScale3D(FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
		Transform.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
		Transform.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers FTransform3f.container-api
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 explicit scale (2,2,2).
// Expected observations: Omitted scale is OneVector. Explicit scale is stored.
// Identity has zero translation, identity rotation, and unit scale.
// Boundary/ownership: Identity is a shared constant. Omitted InScale3D is
// FVector3f::OneVector.
// FTransform3f(Quat/Rotator, Translation, Scale=OneVector): omitted scale is OneVector; yaw 90 is kept.
bool ObserveValueNominal()
{
	FTransform3f FromQuatDefault(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0));
	FTransform3f FromQuatScale(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	FTransform3f FromRotDefault(FRotator3f::ZeroRotator, FVector3f(1.0, 2.0, 3.0));
	FTransform3f FromRotScale(FRotator3f(0.0, 90.0, 0.0), FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	return FromQuatDefault.GetScale3D().Equals(FVector3f::OneVector) &&
		FromRotDefault.GetScale3D().Equals(FVector3f::OneVector) &&
		FromQuatScale.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
		FromRotScale.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
		FromQuatDefault.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
		FromRotScale.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
}
/** @end */
/**
 * @begin ftransform3f-identity-zero-translation
 * @summary FTransform3f::Identity: zero translation, identity rotation, unit scale.
 * @topic Unreal
 */
/**
 * @function ObserveSurface060Nominal
 * @summary FTransform3f::Identity: zero translation, identity rotation, unit scale.
 * @covers FTransform3f.ftransform3f-identity-zero-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface060Nominal()
{
	FTransform3f Identity = FTransform3f::Identity;
	return Identity.GetTranslation().IsNearlyZero() &&
		Identity.GetScale3D().Equals(FVector3f::OneVector) &&
		Identity.GetRotation().Equals(FQuat4f::Identity);
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
 * @covers FTransform3f.get-maximum-axis-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Scale (2,3,4), Identity, child translation 13 vs parent 10, same
// rotation/translation with different scale, default __KINDA_SMALL_NUMBER_flt.
// Expected observations: Max scale is 4, min is 2. Relative translation X is
// 3. Identity rotation is normalized and valid. EqualsNoScale is true across
// scale; Equals is false. GetLocation matches translation. ContainsNaN is
// false.
// Boundary/ownership: Relative queries return new transforms. Equals uses
// tolerance.
bool ObserveGetMaximumAxisScaleNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
	return Scaled.GetMaximumAxisScale() == 4.0 && FTransform3f::Identity.GetMaximumAxisScale() == 1.0;
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
 * @covers FTransform3f.get-minimum-axis-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetMinimumAxisScaleNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
	return Scaled.GetMinimumAxisScale() == 2.0 && FTransform3f::Identity.GetMinimumAxisScale() == 1.0;
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
 * @covers FTransform3f.get-relative-transform
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetRelativeTransformNominal()
{
	FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
	FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
	FTransform3f Relative = Child.GetRelativeTransform(Parent);
	FTransform3f VsIdentity = Child.GetRelativeTransform(FTransform3f::Identity);
	return Relative.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0)) &&
		VsIdentity.GetTranslation().Equals(FVector3f(13.0, 0.0, 0.0));
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
 * @covers FTransform3f.get-relative-transform-reverse
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetRelativeTransformReverseNominal()
{
	FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
	FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
	FTransform3f Reverse = Parent.GetRelativeTransformReverse(Child);
	return Reverse.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0));
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
 * @covers FTransform3f.is-rotation-normalized
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsRotationNormalizedNominal()
{
	FTransform3f FromRotator(FRotator3f(0.0, 90.0, 0.0));
	return FTransform3f::Identity.IsRotationNormalized() && FromRotator.IsRotationNormalized();
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
 * @covers FTransform3f.equals-no-scale
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualsNoScaleNominal()
{
	FTransform3f Base(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	FTransform3f Moved(FQuat4f::Identity, FVector3f(9.0, 0.0, 0.0), FVector3f::OneVector);
	return Base.EqualsNoScale(Scaled) &&
		Base.EqualsNoScale(Scaled, __KINDA_SMALL_NUMBER_flt) &&
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
 * @covers FTransform3f.equals
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEqualsNominal()
{
	FTransform3f Left(FVector3f(1.0, 2.0, 3.0));
	FTransform3f Right(FVector3f(1.0, 2.0, 3.0));
	FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
	return Left.Equals(Right) && Left.Equals(Right, __KINDA_SMALL_NUMBER_flt) && !Left.Equals(Scaled);
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
 * @covers FTransform3f.get-location
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetLocationNominal()
{
	FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
	return Transform.GetLocation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
		FTransform3f::Identity.GetLocation().IsNearlyZero();
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
 * @covers FTransform3f.contains-na-n
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveContainsNaNNominal()
{
	FTransform3f Translated(FVector3f(1.0, 2.0, 3.0));
	return !FTransform3f::Identity.ContainsNaN() && !Translated.ContainsNaN();
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
 * @covers FTransform3f.is-valid
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsValidNominal()
{
	FTransform3f Translated(FVector3f(1.0, 2.0, 3.0));
	return FTransform3f::Identity.IsValid() && Translated.IsValid();
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
 * @covers FTransform3f.get-determinant
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDeterminantNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
	return FTransform3f::Identity.GetDeterminant() == 1.0 && Scaled.GetDeterminant() == 24.0;
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
 * @covers FTransform3f.get-translation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTranslationNominal()
{
	FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
	return Transform.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
		FTransform3f::Identity.GetTranslation().IsNearlyZero();
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
 * @covers FTransform3f.get-scale-3-d
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetScale3DNominal()
{
	FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
	return Scaled.GetScale3D().Equals(FVector3f(2.0, 3.0, 4.0)) &&
		FTransform3f::Identity.GetScale3D().Equals(FVector3f::OneVector);
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
 * @covers FTransform3f.get-rotation
 * @inputs FTransform3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRotationNominal()
{
	FTransform3f Yaw90(FRotator3f(0.0, 90.0, 0.0));
	return FTransform3f::Identity.GetRotation().Equals(FQuat4f::Identity) &&
		!Yaw90.GetRotation().Equals(FQuat4f::Identity);
}
/** @end */
