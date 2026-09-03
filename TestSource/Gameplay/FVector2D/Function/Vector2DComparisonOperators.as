/**
 * The FVector2D equality and inequality operators, each on both a matching and a differing
 * pair. C++ executes each entrypoint and checks the value it produces, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty default and
 * the zero boundary.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.ComparisonOperators
 * @Harness Function
 * @Tag Gameplay.FVector2D.Vector2DComparisonOperators
 * @Namespace FVector2DTest
 * @Provenance Theme: Gameplay.FVector2D. Positive comparison operator oracles.
 * @Provenance C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DComparisonOperators
 * @Provenance Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
 * @Provenance OpNotEquals_False false. Extra: default vector equals FVector2D::ZeroVector;
 * @Provenance ZeroVector != (1,2) true. DefaultSafe.
 */

namespace FVector2DTest
{
	/**
	 * Compare two identical vectors for equality.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpEquals_True()
	{
		FVector2D a = FVector2D(1.5, 2.5);
		FVector2D b = FVector2D(1.5, 2.5);
		return a == b;
	}

	/**
	 * Compare two differing vectors for equality.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpEquals_False()
	{
		FVector2D a = FVector2D(1.5, 2.5);
		FVector2D b = FVector2D(3.0, 4.0);
		return a == b;
	}

	/**
	 * Compare two differing vectors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpNotEquals_True()
	{
		FVector2D a = FVector2D(1.0, 2.0);
		FVector2D b = FVector2D(3.0, 4.0);
		return a != b;
	}

	/**
	 * Compare two identical vectors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpNotEquals_False()
	{
		FVector2D a = FVector2D(5.5, 6.5);
		FVector2D b = FVector2D(5.5, 6.5);
		return a != b;
	}

	/**
	 * Observe that identical vectors compare equal.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true when the entrypoint returned true
	 */
	UFUNCTION()
	bool OpEqualsTrueNominal()
	{
		return OpEquals_True();
	}

	/**
	 * Observe that differing vectors do not compare equal.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true when the entrypoint returned false
	 */
	UFUNCTION()
	bool OpEqualsFalseNominal()
	{
		return !OpEquals_False();
	}

	/**
	 * Observe that differing vectors compare unequal.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true when the entrypoint returned true
	 */
	UFUNCTION()
	bool OpNotEqualsTrueNominal()
	{
		return OpNotEquals_True();
	}

	/**
	 * Observe that identical vectors do not compare unequal.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs none
	 * @Return true when the entrypoint returned false
	 */
	UFUNCTION()
	bool OpNotEqualsFalseNominal()
	{
		return !OpNotEquals_False();
	}

	/**
	 * Observe that a default vector compares equal to the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Empty == FVector2D::ZeroVector;
	}

	/**
	 * Observe that the zero vector compares unequal to a populated one.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ComparisonOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it differs from FVector2D(1.0, 2.0)
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FVector2D Empty = FVector2D();
		return Empty != FVector2D(1.0, 2.0);
	}
}
