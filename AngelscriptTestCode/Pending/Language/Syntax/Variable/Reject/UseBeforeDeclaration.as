/**
 * @version v1
 * @summary A local cannot be read before its declaration.
 * @topic Language
 */
/**
 * @version root
 * @summary A local cannot be read before its declaration.
 * @topic Negative
 */
void Test()
{
	int Y = X;
	int X = 5;
}
/** @end */
