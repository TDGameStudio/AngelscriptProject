/**
 * @version v1
 * @summary A non-const variable as a parameter default is rejected. Defaults must be compile-time constants, not a mutable global. This file is the illegal program itself; do not replace GlobalVal with a literal.
 * @topic Feature
 */
/**
 * @version root
 * @summary A non-const variable as a parameter default is rejected. Defaults must be compile-time constants, not a mutable global. This file is the illegal program itself; do not replace GlobalVal with a literal.
 * @topic Negative
 */
int GlobalVal = 5;

/**
 * Illegal signature: the default names a non-const variable.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X defaulting to GlobalVal
 * @Return does not compile
 * @Param X an int whose default is a mutable global
 */
void Foo(int X = GlobalVal)
{
}
/** @end */
