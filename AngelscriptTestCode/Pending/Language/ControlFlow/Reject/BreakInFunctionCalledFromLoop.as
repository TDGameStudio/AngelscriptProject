/**
 * @version v1
 * @summary A break inside a function that is called from a loop is rejected: break only exits the loop it is lexically inside, and does not propagate out through a call. This file is the illegal program itself; do not move the.
 * @topic Language
 */
/**
 * @version root
 * @summary A break inside a function that is called from a loop is rejected: break only exits the loop it is lexically inside, and does not propagate out through a call. This file is the illegal program itself; do not move the.
 * @topic Negative
 */
/** */
void Foo()
{
	break;
}

/** */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		Foo();
	}
}
/** @end */
