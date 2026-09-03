/**
 * A struct overloads opMul so the binary multiply operator scales its
 * components by an int. Scaling by zero collapses to the zero vector and
 * scaling by one is the identity; the result is always a fresh value.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecMulOverload
 * @Harness Function
 * @Tag Language.Operators.FVecMulOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
 * @Provenance sha256=b181cf048aa7a93f7189a76157435910d9d8c29141aec9b96c4547415f00f26e; lines 85-99.
 * @Provenance C++ AssertCompiles; observations execute opMul.
 * @Provenance Oracle: (2,3)*4=(8,12). Extra: default *0 is (0,0); *1 is identity; result copy is independent.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecMul
	{
		int X = 0;
		int Y = 0;

		/**
		 * Scale both components by an int through the multiply operator.
		 */
		FVecMul opMul(int Scalar) const
		{
			FVecMul Result;
			Result.X = X * Scalar;
			Result.Y = Y * Scalar;
			return Result;
		}
	}

	/**
	 * Observe that opMul scales a populated vector by a scalar.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecMul A = (2,3) scaled by 4
	 * @Return true when the product is (8,12)
	 */
	UFUNCTION()
	bool FVecMulScalesComponents()
	{
		FVecMul A;
		A.X = 2;
		A.Y = 3;
		FVecMul Product = A * 4;

		if (Product.X != 8)
		{
			return false;
		}
		return Product.Y == 12;
	}

	/**
	 * Observe the zero boundary: scaling any vector by zero yields the zero
	 * vector, including a default-constructed one scaled by a non-zero scalar.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs A default FVecMul scaled by 0 and by 5
	 * @Return true when both products are (0,0)
	 * @Boundary zero scalar and default operand
	 */
	UFUNCTION()
	bool FVecMulZeroScalarCollapsesToZero()
	{
		FVecMul A;
		FVecMul Zero = A * 0;
		FVecMul Scaled = A * 5;

		if (Zero.X != 0)
		{
			return false;
		}
		if (Zero.Y != 0)
		{
			return false;
		}
		if (Scaled.X != 0)
		{
			return false;
		}
		return Scaled.Y == 0;
	}

	/**
	 * Observe the identity boundary: scaling by one reproduces the operand, and
	 * the returned product is an independent copy.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecMul A = (6,7) scaled by 1 and by 2, with the latter cleared
	 * @Return true when the identity matches and the operand is unchanged
	 * @Boundary identity scalar
	 */
	UFUNCTION()
	bool FVecMulIdentityPreservesOperand()
	{
		FVecMul A;
		A.X = 6;
		A.Y = 7;
		FVecMul Identity = A * 1;
		FVecMul Product = A * 2;
		Product.X = 0;
		Product.Y = 0;

		if (Identity.X != 6)
		{
			return false;
		}
		if (Identity.Y != 7)
		{
			return false;
		}
		if (A.X != 6)
		{
			return false;
		}
		return A.Y == 7;
	}
}
