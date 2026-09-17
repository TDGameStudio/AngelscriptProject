/**
 * @version v1
 * @summary Iterating an integer literal is rejected: range-for needs a container. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Iterating an integer literal is rejected: range-for needs a container. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	for (int Val : 42)
	{
	}
}
/** @end */
