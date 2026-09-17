/**
 * @version v1
 * @summary A global variable combined with a function that mutates it is rejected. C++ originally expected this to compile, but the assertion is now #if 0 because the combination is unsupported. This file is the illegal program.
 * @topic Language
 */
/**
 * @version root
 * @summary A global variable combined with a function that mutates it is rejected. C++ originally expected this to compile, but the assertion is now #if 0 because the combination is unsupported. This file is the illegal program.
 * @topic Negative
 */
int GlobalCounter = 0;

/**
 * Attempt to increment the global counter from a function.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Increment()
{
	++GlobalCounter;
}
/** @end */
