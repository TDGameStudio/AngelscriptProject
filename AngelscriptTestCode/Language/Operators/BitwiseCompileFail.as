/**
 * @version v1
 * @summary Compile-fail cases for Bitwise.
 * @topic Language
 * @topic Operators
 *
 * invalid-bitwise-on-float               // Bitwise and cannot take float operands.
 * invalid-shift-on-bool                  // Shift operators cannot take boolean operands.
 * invalid-bitwise-and-missing-operand    // Compile-rejection form retained from legacy bitwise and missing operand.
 * invalid-bitwise-and-on-float           // Compile-rejection form retained from legacy bitwise and on float.
 * invalid-bitwise-not-on-string          // Compile-rejection form retained from legacy bitwise not on string.
 * invalid-bitwise-or-on-float            // Compile-rejection form retained from legacy bitwise or on float.
 * invalid-bitwise-xor-on-bool            // Compile-rejection form retained from legacy bitwise xor on bool.
 * invalid-shift-on-float                 // Compile-rejection form retained from legacy shift on float.
 * invalid-shift-on-string                // Compile-rejection form retained from legacy shift on string.
 */
/**
 * @begin invalid-bitwise-on-float
 * @summary Bitwise and cannot take float operands.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f & 2.0f;
}
/** @end */
/**
 * @begin invalid-shift-on-bool
 * @summary Shift operators cannot take boolean operands.
 * @topic Negative
 */
void Test()
{
	bool X = true << 1;
}
/** @end */
/**
 * @begin invalid-bitwise-and-missing-operand
 * @summary Compile-rejection form retained from legacy bitwise and missing operand.
 * @topic Negative
 */
void Test()
{
	int X = 0xFF & ;
}
/** @end */
/**
 * @begin invalid-bitwise-and-on-float
 * @summary Compile-rejection form retained from legacy bitwise and on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f & 2.0f;
}
/** @end */
/**
 * @begin invalid-bitwise-not-on-string
 * @summary Compile-rejection form retained from legacy bitwise not on string.
 * @topic Negative
 */
void Test()
{
	auto S = ~"hello";
}
/** @end */
/**
 * @begin invalid-bitwise-or-on-float
 * @summary Compile-rejection form retained from legacy bitwise or on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f | 2.0f;
}
/** @end */
/**
 * @begin invalid-bitwise-xor-on-bool
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
 * @begin invalid-shift-on-float
 * @summary Compile-rejection form retained from legacy shift on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f << 2;
}
/** @end */
/**
 * @begin invalid-shift-on-string
 * @summary Compile-rejection form retained from legacy shift on string.
 * @topic Negative
 */
void Test()
{
	auto X = "abc" >> 2;
}
/** @end */
