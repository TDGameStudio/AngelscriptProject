/**
 * @version v1
 * @summary Observe FTransform3f scale extrema, relative transforms, equality, location, NaN, and validity.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform3f scale extrema, relative transforms, equality, location, NaN, and validity.
 * @topic Baseline
 */
// GetRelativeTransformReverse; IsRotationNormalized; EqualsNoScale; Equals;
// GetLocation; ContainsNaN; IsValid.
// Inputs: Scale (2,3,4), Identity, child translation 13 vs parent 10, same
// rotation/translation with different scale, default __KINDA_SMALL_NUMBER_flt.
// Expected observations: Max scale is 4, min is 2. Relative translation X is
// 3. Identity rotation is normalized and valid. EqualsNoScale is true across
// scale; Equals is false. GetLocation matches translation. ContainsNaN is
// false.
// Boundary/ownership: Relative queries return new transforms. Equals uses
// tolerance.

namespace TS_FTransform3f_Queries_01
{
	bool Observe_GetMaximumAxisScale_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
		return Scaled.GetMaximumAxisScale() == 4.0 && FTransform3f::Identity.GetMaximumAxisScale() == 1.0;
	}

	bool Observe_GetMinimumAxisScale_Nominal()
	{
		FTransform3f Scaled(FQuat4f::Identity, FVector3f::ZeroVector, FVector3f(2.0, 3.0, 4.0));
		return Scaled.GetMinimumAxisScale() == 2.0 && FTransform3f::Identity.GetMinimumAxisScale() == 1.0;
	}

	bool Observe_GetRelativeTransform_Nominal()
	{
		FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
		FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
		FTransform3f Relative = Child.GetRelativeTransform(Parent);
		FTransform3f VsIdentity = Child.GetRelativeTransform(FTransform3f::Identity);
		return Relative.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0)) &&
			VsIdentity.GetTranslation().Equals(FVector3f(13.0, 0.0, 0.0));
	}

	bool Observe_GetRelativeTransformReverse_Nominal()
	{
		FTransform3f Parent(FVector3f(10.0, 0.0, 0.0));
		FTransform3f Child(FVector3f(13.0, 0.0, 0.0));
		FTransform3f Reverse = Parent.GetRelativeTransformReverse(Child);
		return Reverse.GetTranslation().Equals(FVector3f(3.0, 0.0, 0.0));
	}

	bool Observe_IsRotationNormalized_Nominal()
	{
		FTransform3f FromRotator(FRotator3f(0.0, 90.0, 0.0));
		return FTransform3f::Identity.IsRotationNormalized() && FromRotator.IsRotationNormalized();
	}

	bool Observe_EqualsNoScale_Nominal()
	{
		FTransform3f Base(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f::OneVector);
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		FTransform3f Moved(FQuat4f::Identity, FVector3f(9.0, 0.0, 0.0), FVector3f::OneVector);
		return Base.EqualsNoScale(Scaled) &&
			Base.EqualsNoScale(Scaled, __KINDA_SMALL_NUMBER_flt) &&
			!Base.EqualsNoScale(Moved);
	}

	bool Observe_Equals_Nominal()
	{
		FTransform3f Left(FVector3f(1.0, 2.0, 3.0));
		FTransform3f Right(FVector3f(1.0, 2.0, 3.0));
		FTransform3f Scaled(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		return Left.Equals(Right) && Left.Equals(Right, __KINDA_SMALL_NUMBER_flt) && !Left.Equals(Scaled);
	}

	bool Observe_GetLocation_Nominal()
	{
		FTransform3f Transform(FVector3f(1.0, 2.0, 3.0));
		return Transform.GetLocation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
			FTransform3f::Identity.GetLocation().IsNearlyZero();
	}

	bool Observe_ContainsNaN_Nominal()
	{
		FTransform3f Translated(FVector3f(1.0, 2.0, 3.0));
		return !FTransform3f::Identity.ContainsNaN() && !Translated.ContainsNaN();
	}

	bool Observe_IsValid_Nominal()
	{
		FTransform3f Translated(FVector3f(1.0, 2.0, 3.0));
		return FTransform3f::Identity.IsValid() && Translated.IsValid();
	}
}
/** @end */
