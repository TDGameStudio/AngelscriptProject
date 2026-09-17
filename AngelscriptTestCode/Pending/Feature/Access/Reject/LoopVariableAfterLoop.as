/**
 * @version v1
 * @summary Using a for-loop variable after the loop ends is rejected. This file is the illegal program itself; do not declare I outside the loop, since the out-of-scope read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Using a for-loop variable after the loop ends is rejected. This file is the illegal program itself; do not declare I outside the loop, since the out-of-scope read is the point.
 * @topic Negative
 */
/**
 * Attempt to read the loop counter after the loop ends.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
/** @end */
