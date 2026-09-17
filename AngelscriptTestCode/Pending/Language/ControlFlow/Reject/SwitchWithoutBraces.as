/**
 * @version v1
 * @summary A switch body without braces is rejected: the cases must be grouped in a block. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A switch body without braces is rejected: the cases must be grouped in a block. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1;
	switch (X) case 0: break;
}
/** @end */
