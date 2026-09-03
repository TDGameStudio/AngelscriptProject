/**
 * The bitwise operators: and, or, xor, not, left shift, and right shift, plus a
 * compound combining them. Bitwise not inverts every bit, so it is masked back
 * to a byte to keep the result small enough to compare. Each helper returns
 * the raw result so the caller can assert on the exact value.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseOperators
 * @Harness Function
 * @Tag Language.Operators.BitwiseOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Positive
 * @Provenance sha256=a081c1ffe830d651286fbdf62b7053aa0d0dae0bb281ee5e2950cb62adb424a2; lines 191-199.
 * @Provenance Oracle: BitAnd 15; BitOr 255; BitXor 240; BitNot 255; ShiftLeft 16;
 * @Provenance ShiftRight 4; Compound 255.
 * @Provenance Extra: empty mask 0x00 & 0x0F is 0; 0xFF ^ 0xFF is 0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * And two masks, keeping only the bits both share.
	 */
	int BitAnd()
	{
		return 0xFF & 0x0F;
	}

	/**
	 * Or two masks, keeping every bit either has.
	 */
	int BitOr()
	{
		return 0xF0 | 0x0F;
	}

	/**
	 * Xor two masks, keeping only the bits that differ.
	 */
	int BitXor()
	{
		return 0xFF ^ 0x0F;
	}

	/**
	 * Invert every bit, masked back down to a byte.
	 */
	int BitNot()
	{
		return ~0 & 0xFF;
	}

	/**
	 * Shift a single bit left four places.
	 */
	int ShiftLeft()
	{
		return 1 << 4;
	}

	/**
	 * Shift sixteen right two places.
	 */
	int ShiftRight()
	{
		return 16 >> 2;
	}

	/**
	 * Combine an and with a xor through an or.
	 */
	int Compound()
	{
		return (0xFF & 0x0F) | (0xF0 ^ 0x0F);
	}

	/**
	 * Observe that every operator produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs All seven bitwise forms
	 * @Return true when the results are 15, 255, 240, 255, 16, 4, and 255
	 */
	UFUNCTION()
	bool AllBitwiseFormsProduceExpectedValues()
	{
		if (BitAnd() != 15)
		{
			return false;
		}
		if (BitOr() != 255)
		{
			return false;
		}
		if (BitXor() != 240)
		{
			return false;
		}
		if (BitNot() != 255)
		{
			return false;
		}
		if (ShiftLeft() != 16)
		{
			return false;
		}
		if (ShiftRight() != 4)
		{
			return false;
		}
		return Compound() == 255;
	}

	/**
	 * Observe the empty-mask default: anding with zero clears every bit, and
	 * oring with zero changes nothing.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs 0x00 & 0x0F and 0x00 | BitAnd()
	 * @Return true when the first is 0 and the second equals BitAnd
	 * @Boundary empty mask
	 */
	UFUNCTION()
	bool EmptyMaskClearsAndOrPreserves()
	{
		if ((0x00 & 0x0F) != 0)
		{
			return false;
		}
		return (0x00 | BitAnd()) == BitAnd();
	}

	/**
	 * Observe the full-mask boundary: inverting zero and masking gives the same
	 * result as the not helper, and xoring a value with itself clears it.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs ~0 & 0xFF and 0xFF ^ 0xFF
	 * @Return true when the first equals BitNot and the second is 0
	 * @Boundary full mask
	 */
	UFUNCTION()
	bool FullMaskInvertsAndSelfXorClears()
	{
		if ((~0 & 0xFF) != BitNot())
		{
			return false;
		}
		return (0xFF ^ 0xFF) == 0;
	}
}
