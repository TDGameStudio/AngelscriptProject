/**
 * @version v1
 * @summary A ternary with no true branch is rejected: both branches are required. This file is the illegal program itself; do not insert a true-branch expression, since the missing one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A ternary with no true branch is rejected: both branches are required. This file is the illegal program itself; do not insert a true-branch expression, since the missing one is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = true ? : 0;
}
/** @end */
