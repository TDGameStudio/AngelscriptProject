/**
 * @version v1
 * @summary Assigning a string to an int variable is rejected: there is no implicit conversion from text to a number. This file is the illegal program itself; do not parse the string, since the type mismatch is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning a string to an int variable is rejected: there is no implicit conversion from text to a number. This file is the illegal program itself; do not parse the string, since the type mismatch is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 0;
	X = "hello";
}
/** @end */
