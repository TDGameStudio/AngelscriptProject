/**
 * @version v1
 * @summary The FVector2D arithmetic operators: addition, subtraction, scalar multiply and divide, negation, and the four compound assignment forms. C++ executes each entrypoint and compares the result with the native equivalent, so.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector2D arithmetic operators: addition, subtraction, scalar multiply and divide, negation, and the four compound assignment forms. C++ executes each entrypoint and compares the result with the native equivalent, so.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Add two vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(4.5, 6.5)
	 */
	UFUNCTION()
	FVector2D OpAdd()
	{
		FVector2D a = FVector2D(1.5, 2.5);
		FVector2D b = FVector2D(3.0, 4.0);
		return a + b;
	}

	/**
	 * Subtract two vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(7.0, 15.0)
	 */
	UFUNCTION()
	FVector2D OpSubtract()
	{
		FVector2D a = FVector2D(10.0, 20.0);
		FVector2D b = FVector2D(3.0, 5.0);
		return a - b;
	}

	/**
	 * Scale a vector up.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(8.0, 12.0)
	 */
	UFUNCTION()
	FVector2D OpMultiplyScalar()
	{
		FVector2D v = FVector2D(2.0, 3.0);
		return v * 4.0;
	}

	/**
	 * Scale a vector down.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(10.0, 20.0)
	 */
	UFUNCTION()
	FVector2D OpDivideScalar()
	{
		FVector2D v = FVector2D(20.0, 40.0);
		return v / 2.0;
	}

	/**
	 * Negate a vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(-5.0, -10.0)
	 */
	UFUNCTION()
	FVector2D OpNegate()
	{
		FVector2D v = FVector2D(5.0, 10.0);
		return -v;
	}

	/**
	 * Add onto a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(4.0, 6.0)
	 */
	UFUNCTION()
	FVector2D OpCompoundAdd()
	{
		FVector2D v = FVector2D(1.0, 2.0);
		v += FVector2D(3.0, 4.0);
		return v;
	}

	/**
	 * Subtract from a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(8.0, 10.0)
	 */
	UFUNCTION()
	FVector2D OpCompoundSubtract()
	{
		FVector2D v = FVector2D(10.0, 15.0);
		v -= FVector2D(2.0, 5.0);
		return v;
	}

	/**
	 * Scale a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(6.0, 12.0)
	 */
	UFUNCTION()
	FVector2D OpCompoundMultiply()
	{
		FVector2D v = FVector2D(3.0, 6.0);
		v *= 2.0;
		return v;
	}

	/**
	 * Divide a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector2D(5.0, 10.0)
	 */
	UFUNCTION()
	FVector2D OpCompoundDivide()
	{
		FVector2D v = FVector2D(20.0, 40.0);
		v /= 4.0;
		return v;
	}

	/**
	 * Observe that addition produces the component-wise sum.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(4.5, 6.5)
	 */
	UFUNCTION()
	bool OpAddNominal()
	{
		return OpAdd().Equals(FVector2D(4.5, 6.5));
	}

	/**
	 * Observe that subtraction produces the component-wise difference.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(7.0, 15.0)
	 */
	UFUNCTION()
	bool OpSubtractNominal()
	{
		return OpSubtract().Equals(FVector2D(7.0, 15.0));
	}

	/**
	 * Observe that scalar multiplication scales every component.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(8.0, 12.0)
	 */
	UFUNCTION()
	bool OpMultiplyScalarNominal()
	{
		return OpMultiplyScalar().Equals(FVector2D(8.0, 12.0));
	}

	/**
	 * Observe that scalar division scales every component.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(10.0, 20.0)
	 */
	UFUNCTION()
	bool OpDivideScalarNominal()
	{
		return OpDivideScalar().Equals(FVector2D(10.0, 20.0));
	}

	/**
	 * Observe that negation flips every component.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(-5.0, -10.0)
	 */
	UFUNCTION()
	bool OpNegateNominal()
	{
		return OpNegate().Equals(FVector2D(-5.0, -10.0));
	}

	/**
	 * Observe that compound addition lands on the sum.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(4.0, 6.0)
	 */
	UFUNCTION()
	bool OpCompoundAddNominal()
	{
		return OpCompoundAdd().Equals(FVector2D(4.0, 6.0));
	}

	/**
	 * Observe that compound subtraction lands on the difference.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(8.0, 10.0)
	 */
	UFUNCTION()
	bool OpCompoundSubtractNominal()
	{
		return OpCompoundSubtract().Equals(FVector2D(8.0, 10.0));
	}

	/**
	 * Observe that compound multiplication lands on the scaled value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(6.0, 12.0)
	 */
	UFUNCTION()
	bool OpCompoundMultiplyNominal()
	{
		return OpCompoundMultiply().Equals(FVector2D(6.0, 12.0));
	}

	/**
	 * Observe that compound division lands on the scaled value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector2D(5.0, 10.0)
	 */
	UFUNCTION()
	bool OpCompoundDivideNominal()
	{
		return OpCompoundDivide().Equals(FVector2D(5.0, 10.0));
	}

	/**
	 * Observe that adding to a default vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it and its sum with the zero vector are both the zero vector
	 * @Boundary zero operand
	 */
	UFUNCTION()
	bool OpAddDefaultEmpty()
	{
		FVector2D Empty = FVector2D();

		if (!Empty.Equals(FVector2D::ZeroVector))
		{
			return false;
		}
		return (Empty + FVector2D::ZeroVector).Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating a sum leaves both operands untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ArithmeticOperators
	 * @Inputs two vectors and their mutated sum
	 * @Return true when both operands still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpAddCopyIndependence()
	{
		FVector2D A = FVector2D(1.5, 2.5);
		FVector2D B = FVector2D(3.0, 4.0);
		FVector2D Sum = A + B;
		Sum.X = 0.0;

		if (!A.Equals(FVector2D(1.5, 2.5)))
		{
			return false;
		}
		return B.Equals(FVector2D(3.0, 4.0));
	}
}
/** @end */
