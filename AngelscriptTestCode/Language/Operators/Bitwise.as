/**
 * @version v1
 * @summary Bitwise and shift operator forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary And, or, xor, not, and both shift directions on integers.
 * @topic Baseline
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
 * @version invalid-bitwise-on-float
 * @parent root
 * @summary Bitwise and cannot take float operands.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f & 2.0f;
}
/** @end */
/**
 * @version invalid-shift-on-bool
 * @parent root
 * @summary Shift operators cannot take boolean operands.
 * @topic Negative
 */
void Test()
{
	bool X = true << 1;
}
/** @end */
/**
 * @version invalid-bitwise-and-missing-operand
 * @parent root
 * @summary Compile-rejection form retained from legacy bitwise and missing operand.
 * @topic Negative
 */
void Test()
{
	int X = 0xFF & ;
}
/** @end */
/**
 * @version invalid-bitwise-and-on-float
 * @parent root
 * @summary Compile-rejection form retained from legacy bitwise and on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f & 2.0f;
}
/** @end */
/**
 * @version invalid-bitwise-not-on-string
 * @parent root
 * @summary Compile-rejection form retained from legacy bitwise not on string.
 * @topic Negative
 */
void Test()
{
	auto S = ~"hello";
}
/** @end */
/**
 * @version invalid-bitwise-or-on-float
 * @parent root
 * @summary Compile-rejection form retained from legacy bitwise or on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f | 2.0f;
}
/** @end */
/**
 * @version invalid-bitwise-xor-on-bool
 * @parent root
 * @summary Compile-rejection form retained from legacy bitwise xor on bool.
 * @topic Negative
 */
void Test()
{
	bool A = true;
	bool B = false;
	int X = A ^ B;
}
/** @end */
/**
 * @version invalid-shift-on-float
 * @parent root
 * @summary Compile-rejection form retained from legacy shift on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f << 2;
}
/** @end */
/**
 * @version invalid-shift-on-string
 * @parent root
 * @summary Compile-rejection form retained from legacy shift on string.
 * @topic Negative
 */
void Test()
{
	auto X = "abc" >> 2;
}
/** @end */
/**
 * @version valid-bitmask-protocol
 * @parent root
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
