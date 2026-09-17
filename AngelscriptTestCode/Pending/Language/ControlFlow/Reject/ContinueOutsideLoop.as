/**
 * @version v1
 * @summary A continue outside a loop is rejected: there is no enclosing loop to skip an iteration of. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A continue outside a loop is rejected: there is no enclosing loop to skip an iteration of. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is the point.
 * @topic Negative
 */
/** */
void Test()
{
	continue;
}
/** @end */
