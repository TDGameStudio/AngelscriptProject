/**
 * @version v1
 * @summary Using nullptr in arithmetic is rejected: it is a handle literal and takes no part in numeric expressions. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Using nullptr in arithmetic is rejected: it is a handle literal and takes no part in numeric expressions. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = nullptr + 1;
}
/** @end */
