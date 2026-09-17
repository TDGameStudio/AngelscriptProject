/**
 * @version v1
 * @summary A break inside an if that sits outside any loop is rejected: an if is not a loop, so there is nothing for the break to exit. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is.
 * @topic Language
 */
/**
 * @version root
 * @summary A break inside an if that sits outside any loop is rejected: an if is not a loop, so there is nothing for the break to exit. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is.
 * @topic Negative
 */
/** */
void Test()
{
	if (true)
	{
		break;
	}
}
/** @end */
