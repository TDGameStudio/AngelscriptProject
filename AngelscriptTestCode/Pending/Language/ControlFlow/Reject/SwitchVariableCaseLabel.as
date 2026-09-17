/**
 * @version v1
 * @summary A case label built from a variable is rejected: case labels must be compile-time constants. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A case label built from a variable is rejected: case labels must be compile-time constants. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	int Y = 2;
	switch (X)
	{
		case Y:
			break;
	}
}
/** @end */
