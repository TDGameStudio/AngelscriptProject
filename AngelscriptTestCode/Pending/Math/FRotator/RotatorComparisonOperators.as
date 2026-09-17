/**
 * @version v1
 * @summary The FRotator equality and inequality operators, each on both a matching and a differing pair. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Math
 */
/**
 * @version root
 * @summary The FRotator equality and inequality operators, each on both a matching and a differing pair. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Compare two identical rotators for equality.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpEquals_True()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(10, 20, 30);
		return a == b;
	}

	/**
	 * Compare two differing rotators for equality.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpEquals_False()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(40, 50, 60);
		return a == b;
	}

	/**
	 * Compare two differing rotators for inequality.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpNotEquals_True()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(40, 50, 60);
		return a != b;
	}

	/**
	 * Compare two identical rotators for inequality.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpNotEquals_False()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(10, 20, 30);
		return a != b;
	}

	/**
	 * Observe that all four comparison entrypoints match the oracle.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs none
	 * @Return true when equals-true, equals-false, not-equals-true and not-equals-false hold
	 */
	UFUNCTION()
	bool ComparisonHolds()
	{
		if (OpEquals_True() != true)
		{
			return false;
		}
		if (OpEquals_False() != false)
		{
			return false;
		}
		if (OpNotEquals_True() != true)
		{
			return false;
		}
		return OpNotEquals_False() == false;
	}

	/**
	 * Observe that two empty rotators compare equal.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs two default/zero rotators
	 * @Return true when == is true and != is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyEquals()
	{
		FRotator EmptyA = FRotator();
		FRotator EmptyB = FRotator::ZeroRotator;

		if ((EmptyA == EmptyB) != true)
		{
			return false;
		}
		return (EmptyA != EmptyB) == false;
	}

	/**
	 * Observe that a non-zero rotator is not the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ComparisonOperators
	 * @Inputs FRotator(10, 20, 30) versus ZeroRotator
	 * @Return true when == is false and != is true
	 * @Boundary zero
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		if ((FRotator(10, 20, 30) == FRotator::ZeroRotator) != false)
		{
			return false;
		}
		return (FRotator(10, 20, 30) != FRotator::ZeroRotator) == true;
	}
}
/** @end */
