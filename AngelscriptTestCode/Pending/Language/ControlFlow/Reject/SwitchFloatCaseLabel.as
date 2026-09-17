/**
 * @version v1
 * @summary A floating-point case label is rejected: case labels must be integral constants. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A floating-point case label is rejected: case labels must be integral constants. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		case 1.5f:
			break;
	}
}
/** @end */
