/**
 * @version v1
 * @summary Mixed-operator precedence chains without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * precedence
 * parenthesized-override
 * arithmetic-before-comparison
 * comparison-before-logical
 * bitwise-before-comparison
 * ternary-inside-arithmetic
 * and-versus-or
 */
/**
 * @begin precedence
 * @summary Arithmetic, shift, comparison, bitwise, and logical precedence mixes.
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
 * @begin parenthesized-override
 * @summary Parentheses override the default arithmetic binding.
 * @topic Operators
 */
int ForcedAddFirst()
{
	return (2 + 3) * 4;
}
/** @end */
/**
 * @begin arithmetic-before-comparison
 * @summary Addition binds before equality comparison.
 * @topic Operators
 */
bool ArithmeticBeforeComparison()
{
	return (1 + 2 == 3);
}
/** @end */
/**
 * @begin comparison-before-logical
 * @summary Comparisons bind before logical and.
 * @topic Operators
 */
bool ComparisonBeforeLogical()
{
	return (1 < 2 && 3 < 4);
}
/** @end */
/**
 * @begin bitwise-before-comparison
 * @summary Bitwise and binds before equality.
 * @topic Operators
 */
bool BitwiseBeforeComparison()
{
	return ((0xFF & 0x0F) == 0x0F);
}
/** @end */
/**
 * @begin ternary-inside-arithmetic
 * @summary A parenthesized ternary resolves before surrounding addition.
 * @topic Operators
 */
int TernaryInsideAdd()
{
	return 1 + (true ? 2 : 3);
}
/** @end */
/**
 * @begin and-versus-or
 * @summary Logical and binds tighter than logical or.
 * @topic Operators
 */
bool AndBeforeOr()
{
	return (false || true && false);
}
/** @end */
