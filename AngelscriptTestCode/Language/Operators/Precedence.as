/**
 * @version v1
 * @summary Mixed-operator precedence chains without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Arithmetic, shift, comparison, bitwise, and logical precedence mixes.
 * @topic Baseline
 */
int ArithmeticBindsTighter()
{
	return 2 + 3 * 4 - 1;
}

int ShiftVersusAdd()
{
	return 1 + 2 << 3;
}

int ComparisonVersusArithmetic()
{
	return (1 + 2 < 5 - 1) ? 1 : 0;
}

int BitwiseVersusComparison()
{
	int X = 5;
	bool Result = (X > 0 && (X & 1) == 1);
	return Result ? 1 : 0;
}

int LogicalVersusComparison()
{
	bool Result = (1 < 2 || 3 > 4 && 5 == 6);
	return Result ? 1 : 0;
}
/** @end */
/**
 * @version valid-parenthesized-override
 * @parent root
 * @summary Parentheses override the default arithmetic binding.
 * @topic Operators
 */
int ForcedAddFirst()
{
	return (2 + 3) * 4;
}
/** @end */
/**
 * @version valid-arithmetic-before-comparison
 * @parent root
 * @summary Addition binds before equality comparison.
 * @topic Operators
 */
bool ArithmeticBeforeComparison()
{
	return (1 + 2 == 3);
}
/** @end */
/**
 * @version valid-comparison-before-logical
 * @parent root
 * @summary Comparisons bind before logical and.
 * @topic Operators
 */
bool ComparisonBeforeLogical()
{
	return (1 < 2 && 3 < 4);
}
/** @end */
/**
 * @version valid-bitwise-before-comparison
 * @parent root
 * @summary Bitwise and binds before equality.
 * @topic Operators
 */
bool BitwiseBeforeComparison()
{
	return ((0xFF & 0x0F) == 0x0F);
}
/** @end */
/**
 * @version valid-ternary-inside-arithmetic
 * @parent root
 * @summary A parenthesized ternary resolves before surrounding addition.
 * @topic Operators
 */
int TernaryInsideAdd()
{
	return 1 + (true ? 2 : 3);
}
/** @end */
/**
 * @version valid-and-versus-or
 * @parent root
 * @summary Logical and binds tighter than logical or.
 * @topic Operators
 */
bool AndBeforeOr()
{
	return (false || true && false);
}
/** @end */
