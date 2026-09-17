/**
 * @version v1
 * @summary Applying logical and to two floats is rejected: the operands must be boolean. This file is the illegal program itself; do not convert them, since the non-boolean operands are the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Applying logical and to two floats is rejected: the operands must be boolean. This file is the illegal program itself; do not convert them, since the non-boolean operands are the point.
 * @topic Negative
 */
/** */
void Test()
{
	bool X = 1.0f && 2.0f;
}
/** @end */
