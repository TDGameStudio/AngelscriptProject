/**
 * @version v1
 * @summary A string ternary condition is rejected: the condition must be boolean. This file is the illegal program itself; do not compare the string, since the non-bool condition is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A string ternary condition is rejected: the condition must be boolean. This file is the illegal program itself; do not compare the string, since the non-bool condition is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = "yes" ? 1 : 0;
}
/** @end */
