/**
 * @version v1
 * @summary A call cannot omit a required argument.
 * @topic Language
 */
/**
 * @version root
 * @summary A call cannot omit a required argument.
 * @topic Negative
 */
void Foo(int Left, int Right)
{
}

void Test()
{
	Foo(1);
}
/** @end */
