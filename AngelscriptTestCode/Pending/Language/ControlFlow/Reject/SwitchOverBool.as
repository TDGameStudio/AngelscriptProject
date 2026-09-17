/**
 * @version v1
 * @summary Switching over a bool is rejected: the switch expression must be an integral number, and bool is not accepted here. This file is the illegal program itself; do not rewrite it as an if.
 * @topic Language
 */
/**
 * @version root
 * @summary Switching over a bool is rejected: the switch expression must be an integral number, and bool is not accepted here. This file is the illegal program itself; do not rewrite it as an if.
 * @topic Negative
 */
/** */
int SwitchBool(bool Value)
{
	switch (Value)
	{
		case true:
			return 1;
		case false:
			return 0;
	}
	return -1;
}
/** @end */
