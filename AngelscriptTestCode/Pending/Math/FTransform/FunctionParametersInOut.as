/**
 * @version v1
 * @summary A FTransform passed by mutable reference and rewritten or mutated in place. C++ executes each entrypoint and checks the value written back, so those names are part of the contract and are kept verbatim. The observers.
 * @topic Math
 */
/**
 * @version root
 * @summary A FTransform passed by mutable reference and rewritten or mutated in place. C++ executes each entrypoint and checks the value written back, so those names are part of the contract and are kept verbatim. The observers.
 * @topic Baseline
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
