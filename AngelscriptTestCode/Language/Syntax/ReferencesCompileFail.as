/**
 * @version v1
 * @summary Compile-fail cases for References.
 * @topic Language
 * @topic Syntax
 *
 * invalid-ref-to-literal             // A non-const reference cannot bind a literal.
 * invalid-ref-to-const-then-write    // A const reference cannot be written.
 */
/**
 * @begin invalid-ref-to-literal
 * @summary A non-const reference cannot bind a literal.
 * @topic Negative
 */
void Write(int& Out Value)
{
	Value = 1;
}

void Test()
{
	Write(3);
}
/** @end */
/**
 * @begin invalid-ref-to-const-then-write
 * @summary A const reference cannot be written.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	int& Written = Value;
	Written = 2;
}
/** @end */
