/**
 * @version v1
 * @summary Bitwise and shift operator forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * bitwise-and-int          // Bitwise and of two integer literals.
 * bitwise-or-int           // Bitwise or of two integer literals.
 * bitwise-xor-int          // Bitwise xor of two integer literals.
 * bitwise-not-int          // Bitwise not of an integer literal.
 * shift-left-int           // Integer left shift.
 * shift-right-int          // Integer logical right shift.
 * shift-right-arith-int    // Integer arithmetic right shift using the live >>> token.
 * bitmask-protocol         // Mask, shift, and complementary bit forms on one integer.
 */
/**
 * @begin bitwise-and-int
 * @summary Bitwise and of two integer literals.
 */
int BitwiseAndInt()
{
	return 12 & 10;
}
/** @end */
/**
 * @begin bitwise-or-int
 * @summary Bitwise or of two integer literals.
 * @topic Operators
 */
int BitwiseOrInt()
{
	return 12 | 10;
}
/** @end */
/**
 * @begin bitwise-xor-int
 * @summary Bitwise xor of two integer literals.
 * @topic Operators
 */
int BitwiseXorInt()
{
	return 12 ^ 10;
}
/** @end */
/**
 * @begin bitwise-not-int
 * @summary Bitwise not of an integer literal.
 * @topic Operators
 */
int BitwiseNotInt()
{
	return ~0;
}
/** @end */
/**
 * @begin shift-left-int
 * @summary Integer left shift.
 * @topic Operators
 */
int ShiftLeftInt()
{
	return 1 << 4;
}
/** @end */
/**
 * @begin shift-right-int
 * @summary Integer logical right shift.
 * @topic Operators
 */
int ShiftRightInt()
{
	return 16 >> 2;
}
/** @end */
/**
 * @begin shift-right-arith-int
 * @summary Integer arithmetic right shift using the live >>> token.
 * @topic Operators
 */
int ShiftRightArithInt()
{
	int X = -8;
	return X >>> 2;
}
/** @end */
/**
 * @begin bitmask-protocol
 * @summary Mask, shift, and complementary bit forms on one integer.
 * @topic Operators
 */
int MaskLowNibble(int Value)
{
	return Value & 0x0F;
}

int ShiftIntoPlace(int Value)
{
	return (Value << 4) | MaskLowNibble(Value);
}

int ClearBit(int Value)
{
	return Value & ~1;
}
/** @end */
