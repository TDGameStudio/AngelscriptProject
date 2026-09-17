/**
 * @version v1
 * @summary A non-const reference cannot bind a by-value function return.
 * @topic Language
 */
/**
 * @version root
 * @summary A non-const reference cannot bind a by-value function return.
 * @topic Negative
 */
int MakeValue()
{
	return 1;
}

void Test()
{
	int& Alias = MakeValue();
}
/** @end */
