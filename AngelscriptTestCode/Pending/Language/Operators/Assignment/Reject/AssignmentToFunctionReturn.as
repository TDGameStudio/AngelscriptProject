/**
 * @version v1
 * @summary Assigning to a function call is rejected: the call is not an lvalue and has no storage to write into. This file is the illegal program itself; do not bind the result to a variable, since the call target is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to a function call is rejected: the call is not an lvalue and has no storage to write into. This file is the illegal program itself; do not bind the result to a variable, since the call target is the point.
 * @topic Negative
 */
/** */
int Foo()
{
	return 1;
}

/** */
void Test()
{
	Foo() = 5;
}
/** @end */
