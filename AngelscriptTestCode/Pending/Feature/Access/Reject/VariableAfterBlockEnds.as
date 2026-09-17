/**
 * @version v1
 * @summary Using a block-local variable after the block ends is rejected. This file is the illegal program itself; do not declare X outside the block, since the out-of-scope read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Using a block-local variable after the block ends is rejected. This file is the illegal program itself; do not declare X outside the block, since the out-of-scope read is the point.
 * @topic Negative
 */
/**
 * Attempt to read a block-local after the block ends.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	{
		int X = 1;
	}
	int Y = X;
}
/** @end */
