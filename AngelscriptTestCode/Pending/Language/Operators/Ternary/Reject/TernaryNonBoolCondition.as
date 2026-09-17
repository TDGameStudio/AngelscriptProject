/**
 * @version v1
 * @summary An integer ternary condition is rejected: the condition must be boolean, and this fork does not treat a non-zero integer as true. This file is the illegal program itself; do not wrap the integer in a comparison, since.
 * @topic Language
 */
/**
 * @version root
 * @summary An integer ternary condition is rejected: the condition must be boolean, and this fork does not treat a non-zero integer as true. This file is the illegal program itself; do not wrap the integer in a comparison, since.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 5 ? 1 : 0;
}
/** @end */
