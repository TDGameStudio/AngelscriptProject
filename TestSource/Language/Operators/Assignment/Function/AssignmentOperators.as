/**
 * The assignment operators: a plain assignment plus the ten compound forms
 * that read, combine, and write back. Each helper starts from a known value
 * and returns the result, so the oracle can assert the exact outcome. The
 * bitwise compound forms mask to a nibble or a byte, and the remainder form
 * keeps the division's leftover.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentOperators
 * @Harness Function
 * @Tag Language.Operators.AssignmentOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Positive
 * @Provenance sha256=c95b169b05b2a79e3bd42ddcde359961fa47fc5e1e575c0e91ac1f98e2096f00; lines 447-459.
 * @Provenance Oracle: SimpleAssign 5; AddAssign 5; SubAssign 7; MulAssign 6; DivAssign 5;
 * @Provenance ModAssign 1; BitAndAssign 15; BitOrAssign 255; BitXorAssign 240;
 * @Provenance ShiftLAssign 16; ShiftRAssign 4.
 * @Provenance Extra: SimpleAssign/AddAssign start from 0; BitAndAssign masks to nibble; ModAssign remainder 1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Assign a value over the initial zero.
	 */
	int SimpleAssign()
	{
		int X = 0;
		X = 5;
		return X;
	}

	/**
	 * Add-assign onto zero.
	 */
	int AddAssign()
	{
		int X = 0;
		X += 5;
		return X;
	}

	/**
	 * Subtract-assign from ten.
	 */
	int SubAssign()
	{
		int X = 10;
		X -= 3;
		return X;
	}

	/**
	 * Multiply-assign from two.
	 */
	int MulAssign()
	{
		int X = 2;
		X *= 3;
		return X;
	}

	/**
	 * Divide-assign from ten.
	 */
	int DivAssign()
	{
		int X = 10;
		X /= 2;
		return X;
	}

	/**
	 * Mod-assign, keeping the remainder.
	 */
	int ModAssign()
	{
		int X = 10;
		X %= 3;
		return X;
	}

	/**
	 * And-assign, masking down to a nibble.
	 */
	int BitAndAssign()
	{
		int X = 0xFF;
		X &= 0x0F;
		return X;
	}

	/**
	 * Or-assign, filling out to a full byte.
	 */
	int BitOrAssign()
	{
		int X = 0xF0;
		X |= 0x0F;
		return X;
	}

	/**
	 * Xor-assign, flipping the low nibble.
	 */
	int BitXorAssign()
	{
		int X = 0xFF;
		X ^= 0x0F;
		return X;
	}

	/**
	 * Shift-left-assign from one.
	 */
	int ShiftLAssign()
	{
		int X = 1;
		X <<= 4;
		return X;
	}

	/**
	 * Shift-right-assign from sixteen.
	 */
	int ShiftRAssign()
	{
		int X = 16;
		X >>= 2;
		return X;
	}

	/**
	 * Observe that every assignment form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs All eleven assignment forms
	 * @Return true when every result matches its oracle value
	 */
	UFUNCTION()
	bool AllAssignmentFormsProduceExpectedValues()
	{
		if (SimpleAssign() != 5)
		{
			return false;
		}
		if (AddAssign() != 5)
		{
			return false;
		}
		if (SubAssign() != 7)
		{
			return false;
		}
		if (MulAssign() != 6)
		{
			return false;
		}
		if (DivAssign() != 5)
		{
			return false;
		}
		if (ModAssign() != 1)
		{
			return false;
		}
		if (BitAndAssign() != 15)
		{
			return false;
		}
		if (BitOrAssign() != 255)
		{
			return false;
		}
		if (BitXorAssign() != 240)
		{
			return false;
		}
		if (ShiftLAssign() != 16)
		{
			return false;
		}
		return ShiftRAssign() == 4;
	}

	/**
	 * Observe the write-after-default boundary: both forms that start from zero
	 * end at five.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs The plain and add-assign forms, both starting from zero
	 * @Return true when both end at 5
	 * @Boundary zero start
	 */
	UFUNCTION()
	bool ZeroStartFormsWriteThrough()
	{
		if (SimpleAssign() != 5)
		{
			return false;
		}
		return AddAssign() == 5;
	}

	/**
	 * Observe the mask and remainder boundary: the and-assign masks to a nibble,
	 * the mod-assign keeps the remainder, and the xor-assign flips the low bits.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs The bitwise and remainder compound forms
	 * @Return true when the results are 15, 1, and 240 respectively
	 * @Boundary mask and remainder
	 */
	UFUNCTION()
	bool MaskAndRemainderFormsHold()
	{
		if (BitAndAssign() != 15)
		{
			return false;
		}
		if (ModAssign() != 1)
		{
			return false;
		}
		return BitXorAssign() == 240;
	}
}
