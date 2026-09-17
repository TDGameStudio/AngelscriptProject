/**
 * @version v1
 * @summary A case label outside a switch is rejected: case only appears inside a switch body. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A case label outside a switch is rejected: case only appears inside a switch body. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	case 1:
		int X = 0;
}
/** @end */
