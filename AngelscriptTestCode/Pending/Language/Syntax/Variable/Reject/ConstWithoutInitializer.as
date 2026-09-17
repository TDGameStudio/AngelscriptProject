/**
 * @version v1
 * @summary A const local declared without an initializer is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because const without an initializer is accepted today, but the case remains a reject by intent.
 * @topic Language
 */
/**
 * @version root
 * @summary A const local declared without an initializer is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because const without an initializer is accepted today, but the case remains a reject by intent.
 * @topic Negative
 */
/**
 * Attempt to declare a const local without an initializer.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	const int X;
}
/** @end */
