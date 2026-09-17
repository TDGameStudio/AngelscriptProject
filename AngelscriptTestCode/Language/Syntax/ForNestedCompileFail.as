/**
 * @version v1
 * @summary Compile-fail cases for ForNested.
 * @topic Language
 * @topic Syntax
 *
 * invalid-inner-index-escape                 // A for-declared index is not visible after the loop.
 * invalid-for-loop-variable-escapes-scope    // Compile-rejection form retained from legacy for loop variable escapes scope.
 */
/**
 * @begin invalid-inner-index-escape
 * @summary A for-declared index is not visible after the loop.
 * @topic Negative
 */
int Test()
{
	for (int Index = 0; Index < 1; ++Index)
	{
	}
	return Index;
}
/** @end */
/**
 * @begin invalid-for-loop-variable-escapes-scope
 * @summary Compile-rejection form retained from legacy for loop variable escapes scope.
 * @topic Negative
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
/** @end */
