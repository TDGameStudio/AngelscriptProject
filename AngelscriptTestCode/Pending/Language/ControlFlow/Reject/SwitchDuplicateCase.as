/**
 * @version v1
 * @summary Two case labels with the same value are rejected: the switch could not decide which body to run. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Two case labels with the same value are rejected: the switch could not decide which body to run. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		case 1:
			break;
		case 1:
			break;
	}
}
/** @end */
