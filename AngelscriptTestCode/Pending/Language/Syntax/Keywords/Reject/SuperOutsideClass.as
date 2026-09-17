/**
 * @version v1
 * @summary Calling Super:: outside a class has no parent scope to resolve against, so the program is rejected. This file is the illegal program itself; do not wrap it in a class, since being outside one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Calling Super:: outside a class has no parent scope to resolve against, so the program is rejected. This file is the illegal program itself; do not wrap it in a class, since being outside one is the point.
 * @topic Negative
 */
/**
 * Attempt to call a parent method at global scope.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	Super::BeginPlay();
}
/** @end */
