/**
 * @version v1
 * @summary A while condition that is just an int variable is rejected: the condition must be a boolean expression, not a bare integer. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A while condition that is just an int variable is rejected: the condition must be a boolean expression, not a bare integer. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	while (X)
	{
		break;
	}
}
/** @end */
