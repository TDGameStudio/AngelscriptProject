/**
 * @version v1
 * @summary A non-constant expression as a parameter default is rejected. Defaults must be compile-time constants, not GlobalVal + 1. This file is the illegal program itself; do not replace the expression with a literal.
 * @topic Feature
 */
/**
 * @version root
 * @summary A non-constant expression as a parameter default is rejected. Defaults must be compile-time constants, not GlobalVal + 1. This file is the illegal program itself; do not replace the expression with a literal.
 * @topic Negative
 */
int GlobalVal = 5;

/**
 * Illegal signature: the default is a non-constant expression.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X defaulting to GlobalVal + 1
 * @Return does not compile
 * @Param X an int whose default is not a constant
 */
void Foo(int X = GlobalVal + 1)
{
}
/** @end */
