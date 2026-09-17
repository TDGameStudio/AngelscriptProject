/**
 * @version v1
 * @summary Bitwise and shift operator forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * bitwise
 * bitmask-protocol
 */
/**
 * @begin bitwise
 * @summary And, or, xor, not, and both shift directions on integers.
 */
int BitAnd()
{
	return 12 & 10;
}

int BitOr()
{
	return 12 | 10;
}

int BitXor()
{
	return 12 ^ 10;
}

int BitNot()
{
	return ~0;
}

int ShiftLeft()
{
	return 1 << 4;
}

int ShiftRight()
{
	return 16 >> 2;
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
