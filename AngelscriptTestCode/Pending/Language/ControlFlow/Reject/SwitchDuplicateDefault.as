/**
 * @version v1
 * @summary Two default labels in one switch are rejected: there can be only one fallback. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Two default labels in one switch are rejected: there can be only one fallback. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		default:
			break;
		default:
			break;
	}
}
/** @end */
