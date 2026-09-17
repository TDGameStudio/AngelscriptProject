/**
 * @version v1
 * @summary An unmatched parenthesis inside an expression is rejected. This file is the illegal program itself; do not close the parenthesis, since the missing delimiter is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An unmatched parenthesis inside an expression is rejected. This file is the illegal program itself; do not close the parenthesis, since the missing delimiter is the point.
 * @topic Negative
 */
/**
 * A function whose initializer opens a parenthesis it never closes.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = (1 + 2;
}
/** @end */
