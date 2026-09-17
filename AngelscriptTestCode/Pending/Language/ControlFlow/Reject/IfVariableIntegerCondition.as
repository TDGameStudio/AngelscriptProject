/**
 * @version v1
 * @summary An if condition that is just an int variable is rejected: the condition must be a boolean expression, not a bare integer. This file is the illegal program itself; do not add a comparison, since the bare integer is the.
 * @topic Language
 */
/**
 * @version root
 * @summary An if condition that is just an int variable is rejected: the condition must be a boolean expression, not a bare integer. This file is the illegal program itself; do not add a comparison, since the bare integer is the.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 0;
	if (X)
	{
	}
}
/** @end */
