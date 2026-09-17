/**
 * @version v1
 * @summary Reading a loop variable after its for scope has closed is rejected. This file is the illegal program itself; do not hoist the declaration out of the loop, since the scoped lifetime is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Reading a loop variable after its for scope has closed is rejected. This file is the illegal program itself; do not hoist the declaration out of the loop, since the scoped lifetime is the point.
 * @topic Negative
 */
/**
 * A loop whose counter is read after its scope ends.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
/** @end */
