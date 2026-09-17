/**
 * @version v1
 * @summary A for condition that does not evaluate to bool is rejected. This file is the illegal program itself; do not turn the condition into a comparison, since the non-bool expression is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A for condition that does not evaluate to bool is rejected. This file is the illegal program itself; do not turn the condition into a comparison, since the non-bool expression is the point.
 * @topic Negative
 */
/**
 * A loop whose condition is the loop counter itself.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I; ++I)
	{
	}
}
/** @end */
