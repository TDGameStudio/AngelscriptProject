/**
 * @version v1
 * @summary Iterating a primitive value is rejected: range-for needs a container. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Iterating a primitive value is rejected: range-for needs a container. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 5;
	for (int Val : X)
	{
	}
}
/** @end */
