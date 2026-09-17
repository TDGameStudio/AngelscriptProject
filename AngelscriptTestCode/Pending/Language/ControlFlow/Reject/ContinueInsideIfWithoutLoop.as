/**
 * @version v1
 * @summary A continue inside an if that sits outside any loop is rejected: an if is not a loop, so there is no iteration to skip. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is the.
 * @topic Language
 */
/**
 * @version root
 * @summary A continue inside an if that sits outside any loop is rejected: an if is not a loop, so there is no iteration to skip. This file is the illegal program itself; do not wrap it in a loop, since the missing loop is the.
 * @topic Negative
 */
/** */
void Test()
{
	if (true)
	{
		continue;
	}
}
/** @end */
