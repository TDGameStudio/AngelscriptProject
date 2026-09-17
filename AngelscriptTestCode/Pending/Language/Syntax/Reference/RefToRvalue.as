/**
 * @version v1
 * @summary A non-const reference cannot bind an rvalue expression.
 * @topic Language
 */
/**
 * @version root
 * @summary A non-const reference cannot bind an rvalue expression.
 * @topic Negative
 */
void Test()
{
	int& Alias = 1 + 2;
}
/** @end */
