/**
 * @version v1
 * @summary A for header with only two of its three clauses is rejected. This file is the illegal program itself; do not add the missing clause, since its absence is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A for header with only two of its three clauses is rejected. This file is the illegal program itself; do not add the missing clause, since its absence is the point.
 * @topic Negative
 */
/**
 * A loop whose header stops after the condition.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 10)
	{
	}
}
/** @end */
