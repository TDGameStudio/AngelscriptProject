/**
 * @version v1
 * @summary The FVector arithmetic operators: addition, subtraction, scalar multiply and divide, negation, and the four compound assignment forms. C++ executes each entrypoint and compares the result with the native equivalent, so.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector arithmetic operators: addition, subtraction, scalar multiply and divide, negation, and the four compound assignment forms. C++ executes each entrypoint and compares the result with the native equivalent, so.
 * @topic Baseline
 */
namespace FVectorTest
{
	/**
	 * Add two vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(5, 7, 9)
	 */
	UFUNCTION()
	FVector OpAdd()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a + b;
	}

	/**
	 * Subtract two vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(9, 18, 27)
	 */
	UFUNCTION()
	FVector OpSubtract()
	{
		FVector a = FVector(10, 20, 30);
		FVector b = FVector(1, 2, 3);
		return a - b;
	}

	/**
	 * Scale a vector up.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(6, 9, 12)
	 */
	UFUNCTION()
	FVector OpMultiplyScalar()
	{
		FVector v = FVector(2, 3, 4);
		return v * 3.0;
	}

	/**
	 * Scale a vector down.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(10, 20, 30)
	 */
	UFUNCTION()
	FVector OpDivideScalar()
	{
		FVector v = FVector(20, 40, 60);
		return v / 2.0;
	}

	/**
	 * Negate a vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(-5, -10, -15)
	 */
	UFUNCTION()
	FVector OpNegate()
	{
		FVector v = FVector(5, 10, 15);
		return -v;
	}

	/**
	 * Add onto a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(3, 5, 7)
	 */
	UFUNCTION()
	FVector OpCompoundAdd()
	{
		FVector v = FVector(1, 2, 3);
		v += FVector(2, 3, 4);
		return v;
	}

	/**
	 * Subtract from a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(7, 5, 3)
	 */
	UFUNCTION()
	FVector OpCompoundSubtract()
	{
		FVector v = FVector(10, 10, 10);
		v -= FVector(3, 5, 7);
		return v;
	}

	/**
	 * Scale a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(4, 8, 12)
	 */
	UFUNCTION()
	FVector OpCompoundMultiply()
	{
		FVector v = FVector(2, 4, 6);
		v *= 2.0;
		return v;
	}

	/**
	 * Divide a vector in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return FVector(5, 10, 15)
	 */
	UFUNCTION()
	FVector OpCompoundDivide()
	{
		FVector v = FVector(20, 40, 60);
		v /= 4.0;
		return v;
	}

	/**
	 * Observe that addition produces the component-wise sum.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 7, 9)
	 */
	UFUNCTION()
	bool OpAddNominal()
	{
		return OpAdd().Equals(FVector(5, 7, 9));
	}

	/**
	 * Observe that subtraction produces the component-wise difference.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(9, 18, 27)
	 */
	UFUNCTION()
	bool OpSubtractNominal()
	{
		return OpSubtract().Equals(FVector(9, 18, 27));
	}

	/**
	 * Observe that scalar multiplication scales every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(6, 9, 12)
	 */
	UFUNCTION()
	bool OpMultiplyScalarNominal()
	{
		return OpMultiplyScalar().Equals(FVector(6, 9, 12));
	}

	/**
	 * Observe that scalar division scales every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 20, 30)
	 */
	UFUNCTION()
	bool OpDivideScalarNominal()
	{
		return OpDivideScalar().Equals(FVector(10, 20, 30));
	}

	/**
	 * Observe that negation flips every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(-5, -10, -15)
	 */
	UFUNCTION()
	bool OpNegateNominal()
	{
		return OpNegate().Equals(FVector(-5, -10, -15));
	}

	/**
	 * Observe that compound addition lands on the sum.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(3, 5, 7)
	 */
	UFUNCTION()
	bool OpCompoundAddNominal()
	{
		return OpCompoundAdd().Equals(FVector(3, 5, 7));
	}

	/**
	 * Observe that compound subtraction lands on the difference.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(7, 5, 3)
	 */
	UFUNCTION()
	bool OpCompoundSubtractNominal()
	{
		return OpCompoundSubtract().Equals(FVector(7, 5, 3));
	}

	/**
	 * Observe that compound multiplication lands on the scaled value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(4, 8, 12)
	 */
	UFUNCTION()
	bool OpCompoundMultiplyNominal()
	{
		return OpCompoundMultiply().Equals(FVector(4, 8, 12));
	}

	/**
	 * Observe that compound division lands on the scaled value.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 10, 15)
	 */
	UFUNCTION()
	bool OpCompoundDivideNominal()
	{
		return OpCompoundDivide().Equals(FVector(5, 10, 15));
	}

	/**
	 * Observe that adding to a default vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs a default-constructed vector
	 * @Return true when it and its sum with the zero vector are both the zero vector
	 * @Boundary zero operand
	 */
	UFUNCTION()
	bool OpAddDefaultEmpty()
	{
		FVector Empty = FVector();

		if (!Empty.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return (Empty + FVector::ZeroVector).Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating a sum leaves both operands untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.ArithmeticOperators
	 * @Inputs two vectors and their mutated sum
	 * @Return true when both operands still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpAddCopyIndependence()
	{
		FVector A = FVector(1, 2, 3);
		FVector B = FVector(4, 5, 6);
		FVector Sum = A + B;
		Sum.X = 0.0;

		if (!A.Equals(FVector(1, 2, 3)))
		{
			return false;
		}
		return B.Equals(FVector(4, 5, 6));
	}
}
/** @end */
