/**
 * @version v1
 * @summary Adding two booleans is rejected: booleans have no arithmetic. This file is the illegal program itself; do not declare anything that would compile it away, since the type mismatch is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Adding two booleans is rejected: booleans have no arithmetic. This file is the illegal program itself; do not declare anything that would compile it away, since the type mismatch is the point.
 * @topic Negative
 */
/** */
void Test()
{
	bool A = true;
	bool B = false;
	int X = A + B;
}
/** @end */
