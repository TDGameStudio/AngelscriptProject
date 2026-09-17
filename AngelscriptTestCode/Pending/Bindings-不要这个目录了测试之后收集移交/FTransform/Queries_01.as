/**
 * @version v1
 * @summary Observe FTransform scale extrema, relative transforms, equality, location, NaN, and validity.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform scale extrema, relative transforms, equality, location, NaN, and validity.
 * @topic Baseline
 */
// GetRelativeTransformReverse; IsRotationNormalized; EqualsNoScale; Equals;
// GetLocation; ContainsNaN; IsValid.
// Inputs: Scale (2,3,4), Identity, child translation 13 vs parent 10, same
// rotation/translation with different scale, default KINDA_SMALL_NUMBER.
// Expected observations: Max scale is 4, min is 2. Relative translation X is
// 3. Identity rotation is normalized and valid. EqualsNoScale is true across
// scale; Equals is false. GetLocation matches translation. ContainsNaN is
// false.
// Boundary/ownership: Relative queries return new transforms. Equals uses
// tolerance.

namespace TS_FTransform_Queries_01
{
	bool Observe_GetMaximumAxisScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
		return Scaled.GetMaximumAxisScale() == 4.0 && FTransform::Identity.GetMaximumAxisScale() == 1.0;
	}

	bool Observe_GetMinimumAxisScale_Nominal()
	{
		FTransform Scaled(FQuat::Identity, FVector::ZeroVector, FVector(2.0, 3.0, 4.0));
		return Scaled.GetMinimumAxisScale() == 2.0 && FTransform::Identity.GetMinimumAxisScale() == 1.0;
	}

	bool Observe_GetRelativeTransform_Nominal()
	{
		FTransform Parent(FVector(10.0, 0.0, 0.0));
		FTransform Child(FVector(13.0, 0.0, 0.0));
		FTransform Relative = Child.GetRelativeTransform(Parent);
		FTransform VsIdentity = Child.GetRelativeTransform(FTransform::Identity);
		return Relative.GetTranslation().Equals(FVector(3.0, 0.0, 0.0)) &&
			VsIdentity.GetTranslation().Equals(FVector(13.0, 0.0, 0.0));
	}

	bool Observe_GetRelativeTransformReverse_Nominal()
	{
		FTransform Parent(FVector(10.0, 0.0, 0.0));
		FTransform Child(FVector(13.0, 0.0, 0.0));
		FTransform Reverse = Parent.GetRelativeTransformReverse(Child);
		return Reverse.GetTranslation().Equals(FVector(3.0, 0.0, 0.0));
	}

	bool Observe_IsRotationNormalized_Nominal()
	{
		FTransform FromRotator(FRotator(0.0, 90.0, 0.0));
		return FTransform::Identity.IsRotationNormalized() && FromRotator.IsRotationNormalized();
	}

	bool Observe_EqualsNoScale_Nominal()
	{
		FTransform Base(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector::OneVector);
		FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		FTransform Moved(FQuat::Identity, FVector(9.0, 0.0, 0.0), FVector::OneVector);
		return Base.EqualsNoScale(Scaled) &&
			Base.EqualsNoScale(Scaled, KINDA_SMALL_NUMBER) &&
			!Base.EqualsNoScale(Moved);
	}

	bool Observe_Equals_Nominal()
	{
		FTransform Left(FVector(1.0, 2.0, 3.0));
		FTransform Right(FVector(1.0, 2.0, 3.0));
		FTransform Scaled(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Scaled);
	}

	bool Observe_GetLocation_Nominal()
	{
		FTransform Transform(FVector(1.0, 2.0, 3.0));
		return Transform.GetLocation().Equals(FVector(1.0, 2.0, 3.0)) &&
			FTransform::Identity.GetLocation().IsNearlyZero();
	}

	bool Observe_ContainsNaN_Nominal()
	{
		FTransform Translated(FVector(1.0, 2.0, 3.0));
		return !FTransform::Identity.ContainsNaN() && !Translated.ContainsNaN();
	}

	bool Observe_IsValid_Nominal()
	{
		FTransform Translated(FVector(1.0, 2.0, 3.0));
		return FTransform::Identity.IsValid() && Translated.IsValid();
	}
}
/** @end */
