/**
 * @version v1
 * @summary A float ternary condition is rejected: the condition must be boolean. This file is the illegal program itself; do not compare the float, since the non-bool condition is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A float ternary condition is rejected: the condition must be boolean. This file is the illegal program itself; do not compare the float, since the non-bool condition is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1.0f ? 1 : 0;
}
/** @end */
