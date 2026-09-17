/**
 * @version v1
 * @summary The FLinearColor arithmetic operators: addition, subtraction, scalar and color multiply, scalar divide, and the compound add and multiply forms. C++ executes each entrypoint and compares the result with the native.
 * @topic Math
 */
/**
 * @version root
 * @summary The FLinearColor arithmetic operators: addition, subtraction, scalar and color multiply, scalar divide, and the compound add and multiply forms. C++ executes each entrypoint and compares the result with the native.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Add two colors.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.6, 0.6, 0.6, 0.6)
	 */
	UFUNCTION()
	FLinearColor OpAdd()
	{
		FLinearColor a = FLinearColor(0.1, 0.2, 0.3, 0.4);
		FLinearColor b = FLinearColor(0.5, 0.4, 0.3, 0.2);
		return a + b;
	}

	/**
	 * Subtract two colors.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.8, 0.5, 0.5, 0.3)
	 */
	UFUNCTION()
	FLinearColor OpSubtract()
	{
		FLinearColor a = FLinearColor(1.0, 0.8, 0.6, 0.4);
		FLinearColor b = FLinearColor(0.2, 0.3, 0.1, 0.1);
		return a - b;
	}

	/**
	 * Scale a color up.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.4, 0.8, 1.2, 1.6)
	 */
	UFUNCTION()
	FLinearColor OpMultiplyScalar()
	{
		FLinearColor c = FLinearColor(0.2, 0.4, 0.6, 0.8);
		return c * 2.0;
	}

	/**
	 * Multiply two colors component-wise.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.4, 0.3, 0.2, 1.0)
	 */
	UFUNCTION()
	FLinearColor OpMultiplyColor()
	{
		FLinearColor a = FLinearColor(0.5, 0.5, 0.5, 1.0);
		FLinearColor b = FLinearColor(0.8, 0.6, 0.4, 1.0);
		return a * b;
	}

	/**
	 * Scale a color down.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.5, 0.4, 0.3, 0.2)
	 */
	UFUNCTION()
	FLinearColor OpDivideScalar()
	{
		FLinearColor c = FLinearColor(1.0, 0.8, 0.6, 0.4);
		return c / 2.0;
	}

	/**
	 * Add onto a color in place.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(0.3, 0.3, 0.4, 0.5)
	 */
	UFUNCTION()
	FLinearColor OpCompoundAdd()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		c += FLinearColor(0.2, 0.1, 0.1, 0.1);
		return c;
	}

	/**
	 * Scale a color in place.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return FLinearColor(1.0, 0.8, 0.6, 0.4)
	 */
	UFUNCTION()
	FLinearColor OpCompoundMultiply()
	{
		FLinearColor c = FLinearColor(0.5, 0.4, 0.3, 0.2);
		c *= 2.0;
		return c;
	}

	/**
	 * Observe that addition produces the component-wise sum.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.6, 0.6, 0.6, 0.6)
	 */
	UFUNCTION()
	bool OpAddNominal()
	{
		return OpAdd().Equals(FLinearColor(0.6, 0.6, 0.6, 0.6));
	}

	/**
	 * Observe that subtraction produces the component-wise difference.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.8, 0.5, 0.5, 0.3)
	 */
	UFUNCTION()
	bool OpSubtractNominal()
	{
		return OpSubtract().Equals(FLinearColor(0.8, 0.5, 0.5, 0.3));
	}

	/**
	 * Observe that scalar multiplication scales every component.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.4, 0.8, 1.2, 1.6)
	 */
	UFUNCTION()
	bool OpMultiplyScalarNominal()
	{
		return OpMultiplyScalar().Equals(FLinearColor(0.4, 0.8, 1.2, 1.6));
	}

	/**
	 * Observe that color multiplication scales every component.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.4, 0.3, 0.2, 1.0)
	 */
	UFUNCTION()
	bool OpMultiplyColorNominal()
	{
		return OpMultiplyColor().Equals(FLinearColor(0.4, 0.3, 0.2, 1.0));
	}

	/**
	 * Observe that scalar division scales every component.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.5, 0.4, 0.3, 0.2)
	 */
	UFUNCTION()
	bool OpDivideScalarNominal()
	{
		return OpDivideScalar().Equals(FLinearColor(0.5, 0.4, 0.3, 0.2));
	}

	/**
	 * Observe that compound addition lands on the sum.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (0.3, 0.3, 0.4, 0.5)
	 */
	UFUNCTION()
	bool OpCompoundAddNominal()
	{
		return OpCompoundAdd().Equals(FLinearColor(0.3, 0.3, 0.4, 0.5));
	}

	/**
	 * Observe that compound multiplication lands on the scaled value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals (1.0, 0.8, 0.6, 0.4)
	 */
	UFUNCTION()
	bool OpCompoundMultiplyNominal()
	{
		return OpCompoundMultiply().Equals(FLinearColor(1.0, 0.8, 0.6, 0.4));
	}

	/**
	 * Observe that adding a zero color to a default color keeps alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs a default-constructed color
	 * @Return true when the empty color is (0, 0, 0, 1) and the sum keeps A 1
	 * @Boundary default value
	 */
	UFUNCTION()
	bool OpAddDefaultEmpty()
	{
		FLinearColor Empty = FLinearColor();
		FLinearColor Sum = Empty + FLinearColor(0.0, 0.0, 0.0, 0.0);

		if (!Empty.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0)))
		{
			return false;
		}
		return Sum.A == 1.0;
	}

	/**
	 * Observe that mutating a sum leaves both operands untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ArithmeticOperators
	 * @Inputs two colors and their mutated sum
	 * @Return true when both operands still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpAddCopyIndependence()
	{
		FLinearColor A = FLinearColor(0.1, 0.2, 0.3, 0.4);
		FLinearColor B = FLinearColor(0.5, 0.4, 0.3, 0.2);
		FLinearColor Sum = A + B;
		Sum.R = 0.0;

		if (!A.Equals(FLinearColor(0.1, 0.2, 0.3, 0.4)))
		{
			return false;
		}
		return B.Equals(FLinearColor(0.5, 0.4, 0.3, 0.2));
	}
}
/** @end */
