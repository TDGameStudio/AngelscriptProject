/**
 * @version v1
 * @summary Assigning to a const is rejected: a const binding cannot be written through. This file is the illegal program itself; do not drop the const, since the immutability is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to a const is rejected: a const binding cannot be written through. This file is the illegal program itself; do not drop the const, since the immutability is the point.
 * @topic Negative
 */
/** */
void Test()
{
	const int X = 5;
	X = 10;
}
/** @end */
