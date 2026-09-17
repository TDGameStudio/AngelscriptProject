/**
 * @version v1
 * @summary A for header without semicolons separating its clauses is rejected. This file is the illegal program itself; do not add the semicolons, since their absence is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A for header without semicolons separating its clauses is rejected. This file is the illegal program itself; do not add the semicolons, since their absence is the point.
 * @topic Negative
 */
/**
 * A loop whose header clauses run together without separators.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0 I < 10 ++I)
	{
	}
}
/** @end */
