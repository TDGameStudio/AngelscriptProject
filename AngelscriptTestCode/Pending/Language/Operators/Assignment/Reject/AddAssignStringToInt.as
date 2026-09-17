/**
 * @version v1
 * @summary Add-assigning a string to an int variable is rejected: the compound assignment has no meaning across those types. This file is the illegal program itself; do not parse the string, since the type mismatch is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Add-assigning a string to an int variable is rejected: the compound assignment has no meaning across those types. This file is the illegal program itself; do not parse the string, since the type mismatch is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 0;
	X += "hello";
}
/** @end */
