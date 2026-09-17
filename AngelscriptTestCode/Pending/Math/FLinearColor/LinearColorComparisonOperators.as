/**
 * @version v1
 * @summary The FLinearColor equality and inequality operators, each on both a matching and a differing pair. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept.
 * @topic Math
 */
/**
 * @version root
 * @summary The FLinearColor equality and inequality operators, each on both a matching and a differing pair. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Compare two identical colors for equality.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpEquals_True()
	{
		FLinearColor a = FLinearColor(0.5, 0.6, 0.7, 0.8);
		FLinearColor b = FLinearColor(0.5, 0.6, 0.7, 0.8);
		return a == b;
	}

	/**
	 * Compare two differing colors for equality.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpEquals_False()
	{
		FLinearColor a = FLinearColor(0.5, 0.6, 0.7, 0.8);
		FLinearColor b = FLinearColor(0.5, 0.6, 0.8, 0.8);
		return a == b;
	}

	/**
	 * Compare two differing colors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool OpNotEquals_True()
	{
		FLinearColor a = FLinearColor::Red;
		FLinearColor b = FLinearColor::Blue;
		return a != b;
	}

	/**
	 * Compare two identical colors for inequality.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool OpNotEquals_False()
	{
		FLinearColor a = FLinearColor::White;
		FLinearColor b = FLinearColor::White;
		return a != b;
	}

	/**
	 * Observe that the four comparison entrypoints return the expected flags.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs none
	 * @Return true when equal pairs match and differing pairs do not
	 */
	UFUNCTION()
	bool ComparisonNominal()
	{
		if (!OpEquals_True())
		{
			return false;
		}
		if (OpEquals_False())
		{
			return false;
		}
		if (!OpNotEquals_True())
		{
			return false;
		}
		return !OpNotEquals_False();
	}

	/**
	 * Observe that two default colors compare equal and not unequal.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs two default-constructed colors
	 * @Return true when they compare equal
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ComparisonDefaultEmpty()
	{
		FLinearColor EmptyA = FLinearColor();
		FLinearColor EmptyB = FLinearColor();

		if (!(EmptyA == EmptyB))
		{
			return false;
		}
		return !(EmptyA != EmptyB);
	}

	/**
	 * Observe that black and white compare unequal.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ComparisonOperators
	 * @Inputs black and white
	 * @Return true when they do not compare equal
	 * @Boundary black and white
	 */
	UFUNCTION()
	bool ComparisonBlackWhiteBoundary()
	{
		if (FLinearColor::Black == FLinearColor::White)
		{
			return false;
		}
		return FLinearColor::Black != FLinearColor::White;
	}
}
/** @end */
