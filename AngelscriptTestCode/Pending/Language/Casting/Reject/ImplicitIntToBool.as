/**
 * @version v1
 * @summary Assigning an int to a bool is rejected: an integer is not implicitly truthy, so the comparison has to be written out. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning an int to a bool is rejected: an integer is not implicitly truthy, so the comparison has to be written out. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	bool B = X;
}
/** @end */
