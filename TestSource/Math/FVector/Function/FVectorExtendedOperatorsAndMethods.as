/**
 * The extended FVector operators and methods: component-wise multiply and divide, in-place
 * normalization, the unit checks, squared distance, both projection forms, lerp, both size
 * clamps, axis rotation and the direction-and-length out parameters. C++ executes each
 * entrypoint and compares the result with the native equivalent, so those names are part of
 * the contract and are kept verbatim.
 *
 * @Theme Math.FVector
 * @Subject FVector.ExtendedOperatorsAndMethods
 * @Harness Function
 * @Tag Math.FVector.FVectorExtendedOperatorsAndMethods
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive component-op and method oracles.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorExtendedOperatorsAndMethods
 * @Provenance Oracle: * (10,18,28); / (10,10,10); NormalizeMutates true;
 * @Provenance UnitAndNormalizedChecks true; DistSquared 25.0; ProjectOnTo (3,0,0);
 * @Provenance ProjectOnToNormal (0,4,0); Lerp (2.5,5,7.5); ClampSize (5,0,0);
 * @Provenance ClampMaxSize (0,3,0); RotateAroundZ (0,1,0); DirectionAndLength true.
 * @Provenance Extra: empty ZeroVector DistSquared 0; copy independence of component *.
 * @Provenance DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Multiply two vectors component-wise.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(10, 18, 28)
	 */
	UFUNCTION()
	FVector OpComponentMultiply()
	{
		return FVector(2, 3, 4) * FVector(5, 6, 7);
	}

	/**
	 * Divide two vectors component-wise.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(10, 10, 10)
	 */
	UFUNCTION()
	FVector OpComponentDivide()
	{
		return FVector(20, 30, 40) / FVector(2, 3, 4);
	}

	/**
	 * Multiply two vectors component-wise in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(10, 18, 28)
	 */
	UFUNCTION()
	FVector OpCompoundComponentMultiply()
	{
		FVector v = FVector(2, 3, 4);
		v *= FVector(5, 6, 7);
		return v;
	}

	/**
	 * Divide two vectors component-wise in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(10, 10, 10)
	 */
	UFUNCTION()
	FVector OpCompoundComponentDivide()
	{
		FVector v = FVector(20, 30, 40);
		v /= FVector(2, 3, 4);
		return v;
	}

	/**
	 * Normalize a vector in place and report whether it succeeded.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when Normalize reported success and the vector became the unit X axis
	 */
	UFUNCTION()
	bool NormalizeMutates()
	{
		FVector v = FVector(10, 0, 0);
		bool bNormalized = v.Normalize();

		if (!bNormalized)
		{
			return false;
		}
		return v.Equals(FVector(1, 0, 0), 0.001);
	}

	/**
	 * Ask whether a unit axis vector is both a unit and normalized.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when both flags are set
	 */
	UFUNCTION()
	bool UnitAndNormalizedChecks()
	{
		FVector v = FVector(1, 0, 0);

		if (!v.IsUnit())
		{
			return false;
		}
		return v.IsNormalized();
	}

	/**
	 * Measure the squared distance between two points.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return 25
	 */
	UFUNCTION()
	float DistSquaredMethod()
	{
		return FVector(1, 2, 3).DistSquared(FVector(4, 6, 3));
	}

	/**
	 * Project a vector onto another vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(3, 0, 0)
	 */
	UFUNCTION()
	FVector ProjectOnToVector()
	{
		return FVector(3, 4, 0).ProjectOnTo(FVector(1, 0, 0));
	}

	/**
	 * Project a vector onto a unit direction.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(0, 4, 0)
	 */
	UFUNCTION()
	FVector ProjectOnToNormalVector()
	{
		return FVector(3, 4, 0).ProjectOnToNormal(FVector(0, 1, 0));
	}

	/**
	 * Interpolate a quarter of the way between two vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(2.5, 5, 7.5)
	 */
	UFUNCTION()
	FVector LerpVector()
	{
		return Math::Lerp(FVector(0, 0, 0), FVector(10, 20, 30), 0.25);
	}

	/**
	 * Clamp a vector's length into a range.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(5, 0, 0)
	 */
	UFUNCTION()
	FVector ClampSizeVector()
	{
		return FVector(10, 0, 0).GetClampedToSize(0, 5);
	}

	/**
	 * Clamp a vector's length to a maximum.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(0, 3, 0)
	 */
	UFUNCTION()
	FVector ClampMaxSizeVector()
	{
		return FVector(0, 12, 0).GetClampedToMaxSize(3);
	}

	/**
	 * Rotate a vector ninety degrees about the Z axis.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return FVector(0, 1, 0)
	 */
	UFUNCTION()
	FVector RotateAroundZ()
	{
		return FVector(1, 0, 0).RotateAngleAxis(90, FVector(0, 0, 1));
	}

	/**
	 * Decompose a vector into a direction and a length through out parameters.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the direction reads (0, 0.6, 0.8) and the length is 5
	 */
	UFUNCTION()
	bool DirectionAndLengthOutParams()
	{
		FVector Direction;
		float64 Length = 0;
		FVector(0, 3, 4).ToDirectionAndLength(Direction, Length);

		if (!Direction.Equals(FVector(0, 0.6, 0.8), 0.001))
		{
			return false;
		}
		if (Length <= 4.999)
		{
			return false;
		}
		return Length < 5.001;
	}

	/**
	 * Observe that component-wise multiplication matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 18, 28)
	 */
	UFUNCTION()
	bool OpComponentMultiplyNominal()
	{
		return OpComponentMultiply().Equals(FVector(10, 18, 28));
	}

	/**
	 * Observe that component-wise division matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 10, 10)
	 */
	UFUNCTION()
	bool OpComponentDivideNominal()
	{
		return OpComponentDivide().Equals(FVector(10, 10, 10));
	}

	/**
	 * Observe that in-place component-wise multiplication matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 18, 28)
	 */
	UFUNCTION()
	bool OpCompoundComponentMultiplyNominal()
	{
		return OpCompoundComponentMultiply().Equals(FVector(10, 18, 28));
	}

	/**
	 * Observe that in-place component-wise division matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 10, 10)
	 */
	UFUNCTION()
	bool OpCompoundComponentDivideNominal()
	{
		return OpCompoundComponentDivide().Equals(FVector(10, 10, 10));
	}

	/**
	 * Observe that in-place normalization mutates and reports success.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return NormalizeMutates(), expected true
	 */
	UFUNCTION()
	bool NormalizeMutatesNominal()
	{
		return NormalizeMutates();
	}

	/**
	 * Observe that the unit and normalized flags are both set.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return UnitAndNormalizedChecks(), expected true
	 */
	UFUNCTION()
	bool UnitAndNormalizedChecksNominal()
	{
		return UnitAndNormalizedChecks();
	}

	/**
	 * Observe that the squared distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the squared distance is 25
	 */
	UFUNCTION()
	bool DistSquaredMethodNominal()
	{
		return Math::IsNearlyEqual(DistSquaredMethod(), 25.0);
	}

	/**
	 * Observe that the projection lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(3, 0, 0)
	 */
	UFUNCTION()
	bool ProjectOnToVectorNominal()
	{
		return ProjectOnToVector().Equals(FVector(3, 0, 0));
	}

	/**
	 * Observe that the projection onto a normal lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(0, 4, 0)
	 */
	UFUNCTION()
	bool ProjectOnToNormalVectorNominal()
	{
		return ProjectOnToNormalVector().Equals(FVector(0, 4, 0));
	}

	/**
	 * Observe that the interpolation lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(2.5, 5, 7.5)
	 */
	UFUNCTION()
	bool LerpVectorNominal()
	{
		return LerpVector().Equals(FVector(2.5, 5, 7.5));
	}

	/**
	 * Observe that the size clamp lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 0, 0)
	 */
	UFUNCTION()
	bool ClampSizeVectorNominal()
	{
		return ClampSizeVector().Equals(FVector(5, 0, 0));
	}

	/**
	 * Observe that the maximum size clamp lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(0, 3, 0)
	 */
	UFUNCTION()
	bool ClampMaxSizeVectorNominal()
	{
		return ClampMaxSizeVector().Equals(FVector(0, 3, 0));
	}

	/**
	 * Observe that the axis rotation lands on the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when the result equals FVector(0, 1, 0)
	 */
	UFUNCTION()
	bool RotateAroundZNominal()
	{
		return RotateAroundZ().Equals(FVector(0, 1, 0), 0.001);
	}

	/**
	 * Observe that the direction and length decomposition agrees.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs none
	 * @Return DirectionAndLengthOutParams(), expected true
	 */
	UFUNCTION()
	bool DirectionAndLengthOutParamsNominal()
	{
		return DirectionAndLengthOutParams();
	}

	/**
	 * Observe that the squared distance from an empty vector to the origin is zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs a default-constructed vector
	 * @Return true when the squared distance is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DistSquaredMethodDefaultEmpty()
	{
		FVector Empty = FVector();
		return Math::IsNearlyEqual(Empty.DistSquared(FVector::ZeroVector), 0.0);
	}

	/**
	 * Observe that mutating a component-wise product leaves both operands untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs two vectors and their mutated product
	 * @Return true when both operands still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpComponentMultiplyCopyIndependence()
	{
		FVector A = FVector(2, 3, 4);
		FVector B = FVector(5, 6, 7);
		FVector Product = A * B;
		Product.X = 0.0;

		if (!A.Equals(FVector(2, 3, 4)))
		{
			return false;
		}
		return B.Equals(FVector(5, 6, 7));
	}

	/**
	 * Observe that normalizing an empty vector is refused.
	 *
	 * @Kind Observe
	 * @Covers FVector.ExtendedOperatorsAndMethods
	 * @Inputs a default-constructed vector
	 * @Return true when Normalize reported failure
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool NormalizeMutatesZeroBoundary()
	{
		FVector Empty = FVector();
		return !Empty.Normalize();
	}
}
