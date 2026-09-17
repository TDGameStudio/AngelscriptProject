/**
 * @version v1
 * @summary Incrementing a const is rejected: a const binding has no mutable storage to increment. This file is the illegal program itself; do not drop the const, since the immutability is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Incrementing a const is rejected: a const binding has no mutable storage to increment. This file is the illegal program itself; do not drop the const, since the immutability is the point.
 * @topic Negative
 */
/** */
void Test()
{
	const int X = 5;
	++X;
}
/** @end */
