/**
 * @version v1
 * @summary The interface keyword itself is rejected on this AS 2.33 fork. C++ originally expected this to compile, but the assertion is #if 0 because the fork rejects interfaces. This file is the illegal program itself; do not.
 * @topic Language
 */
/**
 * @version root
 * @summary The interface keyword itself is rejected on this AS 2.33 fork. C++ originally expected this to compile, but the assertion is #if 0 because the fork rejects interfaces. This file is the illegal program itself; do not.
 * @topic Negative
 */
interface UIntfBasic
{
	/**
	 * A method declaration inside the unsupported interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DoSomething();

	/**
	 * A value-returning declaration inside the unsupported interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	int GetValue();
}
/** @end */
