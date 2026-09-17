/**
 * @version v1
 * @summary An enum declaration with no name is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because an anonymous enum trips a preprocessor ensure crash, but the case remains a reject by intent. This file is the.
 * @topic Language
 */
/**
 * @version root
 * @summary An enum declaration with no name is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because an anonymous enum trips a preprocessor ensure crash, but the case remains a reject by intent. This file is the.
 * @topic Negative
 */
enum
{
	Value1
}
/** @end */
