/**
 * @version v1
 * @summary A required parameter after a defaulted parameter is rejected. Once a parameter has a default, every parameter after it must also have one. This file is the illegal program itself; do not add a default for Y.
 * @topic Feature
 */
/**
 * @version root
 * @summary A required parameter after a defaulted parameter is rejected. Once a parameter has a default, every parameter after it must also have one. This file is the illegal program itself; do not add a default for Y.
 * @topic Negative
 */
/**
 * Illegal signature: a required int follows a defaulted int.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X = 5 followed by required int Y
 * @Return does not compile
 * @Param X a defaulted int
 * @Param Y a required int after a default
 */
void Foo(int X = 5, int Y)
{
}
/** @end */
