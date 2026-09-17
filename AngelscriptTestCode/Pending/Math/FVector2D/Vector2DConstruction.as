/**
 * @version v1
 * @summary The FVector2D construction paths: the default constructor, the two-parameter constructor, and the two named constants. C++ executes each entrypoint and compares the result with the native equivalent, so those names are.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector2D construction paths: the default constructor, the two-parameter constructor, and the two named constants. C++ executes each entrypoint and compares the result with the native equivalent, so those names are.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Construct a vector with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return FVector2D(), which should be the zero vector
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FVector2D ConstructDefault()
	{
		return FVector2D();
	}

	/**
	 * Construct a vector from two components.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return FVector2D(3.5, 7.2)
	 */
	UFUNCTION()
	FVector2D ConstructTwoParams()
	{
		return FVector2D(3.5, 7.2);
	}

	/**
	 * Read the zero vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return FVector2D::ZeroVector
	 */
	UFUNCTION()
	FVector2D ConstructZeroVector()
	{
		return FVector2D::ZeroVector;
	}

	/**
	 * Read the unit vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return FVector2D::UnitVector
	 */
	UFUNCTION()
	FVector2D ConstructUnitVector()
	{
		return FVector2D::UnitVector;
	}

	/**
	 * Observe that the default constructor yields the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return true when the default equals the zero vector
	 */
	UFUNCTION()
	bool DefaultNominal()
	{
		return ConstructDefault().Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that the two-parameter constructor keeps its components.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return true when the result equals FVector2D(3.5, 7.2)
	 */
	UFUNCTION()
	bool TwoParamsNominal()
	{
		return ConstructTwoParams().Equals(FVector2D(3.5, 7.2));
	}

	/**
	 * Observe that reading the zero constant yields the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return true when the result equals the zero vector
	 */
	UFUNCTION()
	bool ZeroVectorNominal()
	{
		return ConstructZeroVector().Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that reading the unit constant yields the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs none
	 * @Return true when the result equals the unit vector
	 */
	UFUNCTION()
	bool UnitVectorNominal()
	{
		return ConstructUnitVector().Equals(FVector2D::UnitVector);
	}

	/**
	 * Observe that a default vector reads as the origin on every axis.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs a default-constructed vector
	 * @Return true when both components are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyZero()
	{
		FVector2D Empty = FVector2D();

		if (Empty.X != 0.0)
		{
			return false;
		}
		return Empty.Y == 0.0;
	}

	/**
	 * Observe that mutating a copy leaves the two-parameter result untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.Construction
	 * @Inputs the two-parameter result and a mutated copy of it
	 * @Return true when the original still equals FVector2D(3.5, 7.2) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoParamsCopyIndependence()
	{
		FVector2D Original = ConstructTwoParams();
		FVector2D Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector2D(3.5, 7.2)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
/** @end */
