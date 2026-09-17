/**
 * @version v1
 * @summary Iterating a string literal is rejected: a string is not a container of loop elements here. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Iterating a string literal is rejected: a string is not a container of loop elements here. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	for (int Val : "hello")
	{
	}
}
/** @end */
