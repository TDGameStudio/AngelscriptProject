/**
 * @version v1
 * @summary Using a local before it is declared is rejected. This file is the illegal program itself; do not reorder the declarations, since the forward reference is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Using a local before it is declared is rejected. This file is the illegal program itself; do not reorder the declarations, since the forward reference is the point.
 * @topic Negative
 */
/**
 * Attempt to read a local before declaring it.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int Y = X;
	int X = 5;
}
/** @end */
