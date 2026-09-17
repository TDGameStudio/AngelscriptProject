/**
 * @version v1
 * @summary Using the this keyword outside any class has no referent, so the program is rejected. This file is the illegal program itself; do not wrap it in a class, since being outside one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Using the this keyword outside any class has no referent, so the program is rejected. This file is the illegal program itself; do not wrap it in a class, since being outside one is the point.
 * @topic Negative
 */
/**
 * Attempt to capture this at global scope, where no instance exists.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	auto X = this;
}
/** @end */
