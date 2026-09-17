/**
 * @version v1
 * @summary A for statement without parentheses around its header is rejected. This file is the illegal program itself; do not add the parentheses, since their absence is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A for statement without parentheses around its header is rejected. This file is the illegal program itself; do not add the parentheses, since their absence is the point.
 * @topic Negative
 */
/**
 * A loop whose header is not enclosed in parentheses.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for int I = 0; I < 10; ++I
	{
	}
}
/** @end */
