/**
 * @version v1
 * @summary A call cannot pass a string where an int parameter is required.
 * @topic Language
 */
/**
 * @version root
 * @summary A call cannot pass a string where an int parameter is required.
 * @topic Negative
 */
void Foo(int Amount)
{
}

void Test()
{
	Foo("hello");
}
/** @end */
