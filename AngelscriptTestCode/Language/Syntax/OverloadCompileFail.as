/**
 * @version v1
 * @summary Compile-fail cases for Overload.
 * @topic Language
 * @topic Syntax
 *
 * invalid-duplicate-signature
 * invalid-duplicate-function-signature
 */
/**
 * @begin invalid-duplicate-signature
 * @summary Two functions cannot share the same signature.
 * @topic Negative
 */
int Combine(int Value)
{
	return Value;
}

int Combine(int Value)
{
	return Value + 1;
}
/** @end */
/**
 * @begin invalid-duplicate-function-signature
 * @summary Compile-rejection form retained from legacy duplicate function signature.
 * @topic Negative
 */
void Foo(int X)
{
}

void Foo(int X)
{
}
/** @end */
