/**
 * A struct overloads opAddAssign so the compound plus-assign operator mutates
 * the left operand in place and returns it, letting the operation chain. The
 * right operand is never modified, and repeated application accumulates.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecAddAssignOverload
 * @Harness Function
 * @Tag Language.Operators.FVecAddAssignOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
 * @Provenance ASSyntaxOOAddAssign; lines 164-177;
 * @Provenance sha256=b01668f1e289faef9b420678ef37c585105ea6e295e6ebd538d8cee0b7a2afab.
 * @Provenance Oracle: (1, 2) += (3, 4) yields (4, 6); opAddAssign returns this.
 * @Provenance Extra: default (0, 0) += default stays (0, 0); repeat += accumulates.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecAddAssign
	{
		int X = 0;
		int Y = 0;

		/**
		 * Accumulate another vector into this one and return this for chaining.
		 */
		FVecAddAssign& opAddAssign(const FVecAddAssign&in Other)
		{
			X += Other.X;
			Y += Other.Y;
			return this;
		}
	}

	/**
	 * Observe that plus-assign mutates the left operand component-wise.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecAddAssign Left = (1,2) and Right = (3,4)
	 * @Return true when Left becomes (4,6)
	 */
	UFUNCTION()
	bool FVecAddAssignMutatesLeftOperand()
	{
		FVecAddAssign Left;
		FVecAddAssign Right;
		Left.X = 1;
		Left.Y = 2;
		Right.X = 3;
		Right.Y = 4;
		Left += Right;

		if (Left.X != 4)
		{
			return false;
		}
		return Left.Y == 6;
	}

	/**
	 * Observe the default boundary: plus-assign on two default-constructed
	 * vectors leaves the left operand at the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FVecAddAssign values
	 * @Return true when Left stays (0,0)
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FVecAddAssignDefaultsStayAtZero()
	{
		FVecAddAssign Left;
		FVecAddAssign Right;
		Left += Right;

		if (Left.X != 0)
		{
			return false;
		}
		return Left.Y == 0;
	}

	/**
	 * Observe that repeated plus-assign accumulates into the left operand while
	 * leaving the right operand untouched.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Left plus-assigned Step twice, where Step = (1,2)
	 * @Return true when Left is (2,4) and Step is still (1,2)
	 */
	UFUNCTION()
	bool FVecAddAssignAccumulatesWithoutMutatingRight()
	{
		FVecAddAssign Left;
		FVecAddAssign Step;
		Step.X = 1;
		Step.Y = 2;
		Left += Step;
		Left += Step;

		if (Left.X != 2)
		{
			return false;
		}
		if (Left.Y != 4)
		{
			return false;
		}
		if (Step.X != 1)
		{
			return false;
		}
		return Step.Y == 2;
	}
}
