/**
 * @version v1
 * @summary The broken middle module of the compile-failure lifecycle: the same annotated carrier with a missing semicolon before the closing brace. This file is the illegal program itself; do not add the omitted semicolon, since.
 * @topic Language
 */
/**
 * @version root
 * @summary The broken middle module of the compile-failure lifecycle: the same annotated carrier with a missing semicolon before the closing brace. This file is the illegal program itself; do not add the omitted semicolon, since.
 * @topic Negative
 */
UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * The method whose return statement lacks its semicolon.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION()
/** */
	int GetValue()
	{
		return 8
	}
}
/** @end */
