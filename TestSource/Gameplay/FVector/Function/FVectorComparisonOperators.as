/**
 * The FVector equality and inequality operators, each on both a matching and a differing
 * pair. C++ executes each entrypoint and checks the value it produces, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty default and
 * the zero boundary.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.ComparisonOperators
 * @Harness Function
 * @Tag Gameplay.FVector.FVectorComparisonOperators
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive comparison operator oracles.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorComparisonOperators
 * @Provenance Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
 * @Provenance OpNotEquals_False false. Extra: default vector equals FVector::ZeroVector;
 * @Provenance ZeroVector != (1,2,3) true. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Compare two identical vectors for equality.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpEquals_True()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(1, 2, 3);
		return a == b;
	}

	/**
	 * Compare two differing vectors for equality.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpEquals_False()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a == b;
	}

	/**
	 * Compare two differing vectors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpNotEquals_True()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a != b;
	}

	/**
	 * Compare two identical vectors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpNotEquals_False()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(1, 2, 3);
		return a != b;
	}

	/**
	 * Observe that identical vectors compare equal.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
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
	 * @Covers FVector.ComparisonOperators
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
	 * @Covers FVector.ComparisonOperators
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
	 * @Covers FVector.ComparisonOperators
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
	 * @Covers FVector.ComparisonOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		FVector Empty = FVector();
		return Empty == FVector::ZeroVector;
	}

	/**
	 * Observe that the zero vector compares unequal to a populated one.
	 *
	 * @Kind Observe
	 * @Covers FVector.ComparisonOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it differs from FVector(1, 2, 3)
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FVector Empty = FVector();
		return Empty != FVector(1, 2, 3);
	}
}
