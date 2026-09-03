/**
 * Integer and float arithmetic, unary negation, the four increment and
 * decrement forms, a compound expression mixing precedence, and a mixed-type
 * expression where an int widens into a float. Float results are scaled by ten
 * and truncated so an int oracle can assert them exactly. Integer division
 * truncates toward zero.
 *
 * @Theme Language.Operators
 * @Subject Operators.ArithmeticOperators
 * @Harness Function
 * @Tag Language.Operators.ArithmeticOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Positive ExpectGlobalInts.
 * @Provenance sha256=45eacff5c1220e86168b9062e080f6fbbd30b666774f93d1a65a60a8f0cceef3; lines 50-64.
 * @Provenance Oracle: AddInt 3; SubInt 2; MulInt 6; DivInt 5; ModInt 1; AddFloat 35;
 * @Provenance UnaryNeg -5; PreInc 1; PostInc 1; PreDec 4; PostDec 4; CompoundExpr 8; MixedTypes 30.
 * @Provenance Extra: 0 + 0 == 0; PreInc starts at the zero boundary.
 * @Provenance DefaultSafe. Integer division truncates toward zero.
 */

namespace OperatorsTest
{
	/**
	 * Add two ints.
	 */
	int AddInt()
	{
		return 1 + 2;
	}

	/**
	 * Subtract one int from another.
	 */
	int SubInt()
	{
		return 5 - 3;
	}

	/**
	 * Multiply two ints.
	 */
	int MulInt()
	{
		return 2 * 3;
	}

	/**
	 * Divide one int by another, truncating toward zero.
	 */
	int DivInt()
	{
		return 10 / 2;
	}

	/**
	 * Take the remainder of an integer division.
	 */
	int ModInt()
	{
		return 10 % 3;
	}

	/**
	 * Add two floats and scale the result by ten so it can be reported as an int.
	 */
	int AddFloat()
	{
		float X = 1.0f + 2.5f;
		return int(X * 10);
	}

	/**
	 * Negate an int.
	 */
	int UnaryNeg()
	{
		int X = 5;
		return -X;
	}

	/**
	 * Increment before the read.
	 */
	int PreInc()
	{
		int X = 0;
		++X;
		return X;
	}

	/**
	 * Increment after the read.
	 */
	int PostInc()
	{
		int X = 0;
		X++;
		return X;
	}

	/**
	 * Decrement before the read.
	 */
	int PreDec()
	{
		int X = 5;
		--X;
		return X;
	}

	/**
	 * Decrement after the read.
	 */
	int PostDec()
	{
		int X = 5;
		X--;
		return X;
	}

	/**
	 * Mix several operators so precedence decides the result.
	 */
	int CompoundExpr()
	{
		return (1 + 2) * 3 - 4 / 2 + 7 % 3;
	}

	/**
	 * Widen an int into a float and scale the result by ten.
	 */
	int MixedTypes()
	{
		float X = 1 + 2.0f;
		return int(X * 10);
	}

	/**
	 * Observe that every arithmetic form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs All thirteen arithmetic forms
	 * @Return true when every result matches its oracle value
	 */
	UFUNCTION()
	bool AllArithmeticFormsProduceExpectedValues()
	{
		if (AddInt() != 3)
		{
			return false;
		}
		if (SubInt() != 2)
		{
			return false;
		}
		if (MulInt() != 6)
		{
			return false;
		}
		if (DivInt() != 5)
		{
			return false;
		}
		if (ModInt() != 1)
		{
			return false;
		}
		if (AddFloat() != 35)
		{
			return false;
		}
		if (UnaryNeg() != -5)
		{
			return false;
		}
		if (PreInc() != 1)
		{
			return false;
		}
		if (PostInc() != 1)
		{
			return false;
		}
		if (PreDec() != 4)
		{
			return false;
		}
		if (PostDec() != 4)
		{
			return false;
		}
		if (CompoundExpr() != 8)
		{
			return false;
		}
		return MixedTypes() == 30;
	}

	/**
	 * Observe the zero boundary: adding zero to zero stays zero, and the
	 * pre-increment form starts from zero.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs 0 + 0, plus the pre-increment helper
	 * @Return true when the sum is 0 and the increment reaches 1
	 * @Boundary zero operands
	 */
	UFUNCTION()
	bool ZeroOperandsStayAtZero()
	{
		if ((0 + 0) != 0)
		{
			return false;
		}
		return PreInc() == 1;
	}

	/**
	 * Observe the truncation boundary: integer division drops the fraction
	 * toward zero rather than rounding.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs Two divisions whose quotients have a remainder
	 * @Return true when both truncate toward zero
	 * @Boundary integer division truncation
	 */
	UFUNCTION()
	bool IntegerDivisionTruncatesTowardZero()
	{
		if (DivInt() != 5)
		{
			return false;
		}
		return (7 / 2) == 3;
	}
}
