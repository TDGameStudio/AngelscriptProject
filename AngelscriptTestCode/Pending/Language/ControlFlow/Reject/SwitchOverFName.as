/**
 * @version v1
 * @summary Switching over an FName is rejected: the switch expression must be an integral number. This file is the illegal program itself; do not rewrite it as a chain of comparisons.
 * @topic Language
 */
/**
 * @version root
 * @summary Switching over an FName is rejected: the switch expression must be an integral number. This file is the illegal program itself; do not rewrite it as a chain of comparisons.
 * @topic Negative
 */
/** */
int SwitchFName(FName Name)
{
	switch (Name)
	{
		case n"Alpha":
			return 1;
		default:
			return 0;
	}
}
/** @end */
