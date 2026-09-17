/**
 * @version v1
 * @summary A string case label is rejected: case labels must be integral constants. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A string case label is rejected: case labels must be integral constants. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		case "hello":
			break;
	}
}
/** @end */
