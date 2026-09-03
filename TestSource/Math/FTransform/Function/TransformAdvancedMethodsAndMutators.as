/**
 * The FTransform advanced method and mutator paths: TransformRotation,
 * InverseTransformRotation round-trip, NoScale transforms, const getter composition,
 * multiply-assign, SetTranslationAndScale3D, translation and scaling mutators,
 * EqualsNoScale, TranslationEquals and axis-scale sums. C++ executes each entrypoint
 * and checks the value it produces, so those names are part of the contract and are
 * kept verbatim.
 *
 * @Theme Math.FTransform
 * @Subject FTransform.AdvancedMethodsAndMutators
 * @Harness Function
 * @Tag Math.FTransform.TransformAdvancedMethodsAndMutators
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive advanced method / mutator oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformAdvancedMethodsAndMutators
 * @Provenance Oracle: TransformRotation native; InverseTransformRotation round-trip Local;
 * @Provenance TransformPositionNoScale / TransformVectorNoScale native;
 * @Provenance InverseTransformPositionNoScale round-trip (1,2,3); ConstGetterComposition (8,11,14);
 * @Provenance MultiplyAssign native; SetTranslationAndScale native;
 * @Provenance MutateTranslationAndScaling (11,15,19); CompareNoScale true; CompareTranslationOnly true;
 * @Provenance AxisScaleSum 7.
 * @Provenance Extra: AxisScaleSum of Identity is 2; copy independence of Local quat. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Transform a local rotation through a yaw-90 transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return TransformRotation of FQuat(FRotator(10, 20, 30))
	 */
	UFUNCTION()
	FQuat TransformRotation()
	{
		FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
		FQuat Local = FQuat(FRotator(10, 20, 30));
		return T.TransformRotation(Local);
	}

	/**
	 * Round-trip a local rotation through TransformRotation and InverseTransformRotation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return the original local quaternion
	 */
	UFUNCTION()
	FQuat InverseTransformRotationRoundTrip()
	{
		FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
		FQuat Local = FQuat(FRotator(10, 20, 30));
		return T.InverseTransformRotation(T.TransformRotation(Local));
	}

	/**
	 * Transform a local point ignoring scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return TransformPositionNoScale of (1, 2, 3)
	 */
	UFUNCTION()
	FVector TransformPositionNoScale()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return T.TransformPositionNoScale(FVector(1, 2, 3));
	}

	/**
	 * Transform a local vector ignoring scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return TransformVectorNoScale of (1, 2, 3)
	 */
	UFUNCTION()
	FVector TransformVectorNoScale()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return T.TransformVectorNoScale(FVector(1, 2, 3));
	}

	/**
	 * Round-trip a local point through TransformPositionNoScale and its inverse.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return the original local point (1, 2, 3)
	 */
	UFUNCTION()
	FVector InverseTransformPositionNoScaleRoundTrip()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		FVector Local = FVector(1, 2, 3);
		return T.InverseTransformPositionNoScale(T.TransformPositionNoScale(Local));
	}

	/**
	 * Sum location, translation and scale from a const transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return (8, 11, 14)
	 */
	UFUNCTION()
	FVector ConstGetterComposition()
	{
		const FTransform T = FTransform(FQuat::Identity, FVector(3, 4, 5), FVector(2, 3, 4));
		return T.GetLocation() + T.GetTranslation() + T.GetScale3D();
	}

	/**
	 * Multiply-assign two translations.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return T *= FTransform((0, 2, 0)) starting from (1, 0, 0)
	 */
	UFUNCTION()
	FTransform MultiplyAssign()
	{
		FTransform T = FTransform(FVector(1, 0, 0));
		T *= FTransform(FVector(0, 2, 0));
		return T;
	}

	/**
	 * Write translation and scale together onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return identity with translation (7, 8, 9) and scale (2, 3, 4)
	 */
	UFUNCTION()
	FTransform SetTranslationAndScale()
	{
		FTransform T = FTransform::Identity;
		T.SetTranslationAndScale3D(FVector(7, 8, 9), FVector(2, 3, 4));
		return T;
	}

	/**
	 * Mutate location, add a translation, set scale, scale translation and remove scaling.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return GetLocation + GetScale3D after the mutators, expected (11, 15, 19)
	 */
	UFUNCTION()
	FVector MutateTranslationAndScaling()
	{
		FTransform T = FTransform::Identity;
		T.SetLocation(FVector(1, 2, 3));
		T.AddToTranslation(FVector(4, 5, 6));
		T.SetScale3D(FVector(2, 3, 4));
		T.ScaleTranslation(2.0);
		T.RemoveScaling();
		return T.GetLocation() + T.GetScale3D();
	}

	/**
	 * Compare two transforms that share rotation and translation but differ in scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool CompareNoScale()
	{
		FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
		return A.EqualsNoScale(B, 0.001);
	}

	/**
	 * Compare two transforms that share translation but differ in rotation and scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool CompareTranslationOnly()
	{
		FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
		FTransform B = FTransform(FQuat(FRotator(0, 90, 0)), FVector(1, 2, 3), FVector(4, 5, 6));
		return A.TranslationEquals(B, 0.001);
	}

	/**
	 * Sum the maximum and minimum axis scales.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return 7.0
	 */
	UFUNCTION()
	float AxisScaleSum()
	{
		FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 5, 3));
		return T.GetMaximumAxisScale() + T.GetMinimumAxisScale();
	}

	/**
	 * Observe that TransformRotation matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals the native TransformRotation
	 */
	UFUNCTION()
	bool TransformRotationNominal()
	{
		FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
		FQuat Local = FQuat(FRotator(10, 20, 30));
		return TransformRotation().Equals(T.TransformRotation(Local), 0.001);
	}

	/**
	 * Observe that the rotation round-trip recovers the local quaternion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals FQuat(FRotator(10, 20, 30))
	 */
	UFUNCTION()
	bool InverseTransformRotationRoundTripNominal()
	{
		FQuat Local = FQuat(FRotator(10, 20, 30));
		return InverseTransformRotationRoundTrip().Equals(Local, 0.001);
	}

	/**
	 * Observe that TransformPositionNoScale matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals the native TransformPositionNoScale
	 */
	UFUNCTION()
	bool TransformPositionNoScaleNominal()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return TransformPositionNoScale().Equals(T.TransformPositionNoScale(FVector(1, 2, 3)), 0.001);
	}

	/**
	 * Observe that TransformVectorNoScale matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals the native TransformVectorNoScale
	 */
	UFUNCTION()
	bool TransformVectorNoScaleNominal()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return TransformVectorNoScale().Equals(T.TransformVectorNoScale(FVector(1, 2, 3)), 0.001);
	}

	/**
	 * Observe that the NoScale position round-trip recovers (1, 2, 3).
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals (1, 2, 3)
	 */
	UFUNCTION()
	bool InverseTransformPositionNoScaleRoundTripNominal()
	{
		return InverseTransformPositionNoScaleRoundTrip().Equals(FVector(1, 2, 3), 0.001);
	}

	/**
	 * Observe that const getters compose to (8, 11, 14).
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when the result equals (8, 11, 14)
	 */
	UFUNCTION()
	bool ConstGetterCompositionNominal()
	{
		return ConstGetterComposition().Equals(FVector(8, 11, 14), 0.001);
	}

	/**
	 * Observe that multiply-assign matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when MultiplyAssign equals the native *=
	 */
	UFUNCTION()
	bool MultiplyAssignNominal()
	{
		FTransform Expected = FTransform(FVector(1, 0, 0));
		Expected *= FTransform(FVector(0, 2, 0));
		return MultiplyAssign().Equals(Expected, 0.001);
	}

	/**
	 * Observe that SetTranslationAndScale3D matches the native write.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when SetTranslationAndScale equals the native result
	 */
	UFUNCTION()
	bool SetTranslationAndScaleNominal()
	{
		FTransform Expected = FTransform::Identity;
		Expected.SetTranslationAndScale3D(FVector(7, 8, 9), FVector(2, 3, 4));
		return SetTranslationAndScale().Equals(Expected, 0.001);
	}

	/**
	 * Observe that the mutator chain yields (11, 15, 19).
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when MutateTranslationAndScaling equals (11, 15, 19)
	 */
	UFUNCTION()
	bool MutateTranslationAndScalingNominal()
	{
		return MutateTranslationAndScaling().Equals(FVector(11, 15, 19), 0.001);
	}

	/**
	 * Observe that EqualsNoScale holds.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when CompareNoScale is true
	 */
	UFUNCTION()
	bool CompareNoScaleHolds()
	{
		return CompareNoScale() == true;
	}

	/**
	 * Observe that TranslationEquals holds.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when CompareTranslationOnly is true
	 */
	UFUNCTION()
	bool CompareTranslationOnlyHolds()
	{
		return CompareTranslationOnly() == true;
	}

	/**
	 * Observe that the axis-scale sum is 7.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs none
	 * @Return true when AxisScaleSum is 7
	 */
	UFUNCTION()
	bool AxisScaleSumNominal()
	{
		return AxisScaleSum() == 7.0;
	}

	/**
	 * Observe that identity axis scales sum to 2.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs a default-constructed transform
	 * @Return true when max + min axis scale is 2
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AxisScaleSumDefaultIdentity()
	{
		FTransform Empty = FTransform();
		return Empty.GetMaximumAxisScale() + Empty.GetMinimumAxisScale() == 2.0;
	}

	/**
	 * Observe that mutating the world quaternion leaves the local quaternion untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.AdvancedMethodsAndMutators
	 * @Inputs a local quaternion transformed to world and then mutated
	 * @Return true when the local quaternion still equals FQuat(FRotator(10, 20, 30))
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool InverseTransformRotationCopyIndependence()
	{
		FQuat Local = FQuat(FRotator(10, 20, 30));
		FTransform T = FTransform(FRotator(0, 90, 0), FVector(100, 0, 0), FVector(2, 3, 4));
		FQuat World = T.TransformRotation(Local);
		World.X = 0.0;
		return Local.Equals(FQuat(FRotator(10, 20, 30)), 0.001);
	}
}
