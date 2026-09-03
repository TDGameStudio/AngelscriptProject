/**
 * The FVector construction paths: the default constructor, the three-parameter
 * constructor, the single-value broadcast, and the four named constants. C++ executes
 * each entrypoint and compares the result with the native equivalent, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty default and
 * the independence of a copy.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.Construction
 * @Harness Function
 * @Tag Gameplay.FVector.FVectorConstruction
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive construction oracles.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorConstruction
 * @Provenance Oracle: default/ZeroVector (0,0,0); three-param (1,2,3); single (5,5,5);
 * @Provenance OneVector (1,1,1); Forward (1,0,0); Right (0,1,0); Up (0,0,1).
 * @Provenance Extra: empty ZeroVector; copy independence of three-param. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Construct a vector with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector(), which should be the zero vector
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FVector ConstructDefault()
	{
		return FVector();
	}

	/**
	 * Construct a vector from three components.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector(1, 2, 3)
	 */
	UFUNCTION()
	FVector ConstructThreeParams()
	{
		return FVector(1, 2, 3);
	}

	/**
	 * Construct a vector from one value broadcast to every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector(5, 5, 5)
	 */
	UFUNCTION()
	FVector ConstructSingleValue()
	{
		return FVector(5);
	}

	/**
	 * Read the zero vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector::ZeroVector
	 */
	UFUNCTION()
	FVector ConstructZeroVector()
	{
		return FVector::ZeroVector;
	}

	/**
	 * Read the one vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector::OneVector
	 */
	UFUNCTION()
	FVector ConstructOneVector()
	{
		return FVector::OneVector;
	}

	/**
	 * Read the forward vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector::ForwardVector
	 */
	UFUNCTION()
	FVector ConstructForwardVector()
	{
		return FVector::ForwardVector;
	}

	/**
	 * Read the right vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector::RightVector
	 */
	UFUNCTION()
	FVector ConstructRightVector()
	{
		return FVector::RightVector;
	}

	/**
	 * Read the up vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return FVector::UpVector
	 */
	UFUNCTION()
	FVector ConstructUpVector()
	{
		return FVector::UpVector;
	}

	/**
	 * Observe that the default constructor yields the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the default equals the zero vector
	 */
	UFUNCTION()
	bool DefaultNominal()
	{
		return ConstructDefault().Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that the three-parameter constructor keeps its components.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals FVector(1, 2, 3)
	 */
	UFUNCTION()
	bool ThreeParamsNominal()
	{
		return ConstructThreeParams().Equals(FVector(1, 2, 3));
	}

	/**
	 * Observe that the single-value constructor broadcasts to every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 5, 5)
	 */
	UFUNCTION()
	bool SingleValueNominal()
	{
		return ConstructSingleValue().Equals(FVector(5, 5, 5));
	}

	/**
	 * Observe that reading the zero constant yields the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals the zero vector
	 */
	UFUNCTION()
	bool ZeroVectorNominal()
	{
		return ConstructZeroVector().Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that reading the one constant yields the one vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals the one vector
	 */
	UFUNCTION()
	bool OneVectorNominal()
	{
		return ConstructOneVector().Equals(FVector::OneVector);
	}

	/**
	 * Observe that reading the forward constant yields the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals the forward vector
	 */
	UFUNCTION()
	bool ForwardVectorNominal()
	{
		return ConstructForwardVector().Equals(FVector::ForwardVector);
	}

	/**
	 * Observe that reading the right constant yields the right vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals the right vector
	 */
	UFUNCTION()
	bool RightVectorNominal()
	{
		return ConstructRightVector().Equals(FVector::RightVector);
	}

	/**
	 * Observe that reading the up constant yields the up vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs none
	 * @Return true when the result equals the up vector
	 */
	UFUNCTION()
	bool UpVectorNominal()
	{
		return ConstructUpVector().Equals(FVector::UpVector);
	}

	/**
	 * Observe that a default vector reads as the origin on every axis.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs a default-constructed vector
	 * @Return true when all three components are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyZero()
	{
		FVector Empty = FVector();

		if (Empty.X != 0.0)
		{
			return false;
		}
		if (Empty.Y != 0.0)
		{
			return false;
		}
		return Empty.Z == 0.0;
	}

	/**
	 * Observe that mutating a copy leaves the three-parameter result untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.Construction
	 * @Inputs the three-parameter result and a mutated copy of it
	 * @Return true when the original still equals FVector(1, 2, 3) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ThreeParamsCopyIndependence()
	{
		FVector Original = ConstructThreeParams();
		FVector Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector(1, 2, 3)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
