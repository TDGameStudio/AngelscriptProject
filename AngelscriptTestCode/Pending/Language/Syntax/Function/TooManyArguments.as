/**
 * @version v1
 * @summary A call cannot pass more arguments than the function declares.
 * @topic Language
 */
/**
 * @version root
 * @summary A call cannot pass more arguments than the function declares.
 * @topic Negative
 */
void Foo(int Amount)
{
}

void Test()
{
	Foo(1, 2);
}
/** @end */
