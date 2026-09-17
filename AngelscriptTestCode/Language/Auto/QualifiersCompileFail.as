/**
 * @version v1
 * @summary const auto forms that do not compile.
 * @topic Language
 * @topic Auto
 *
 * invalid-const-auto-reassign    // A const auto local cannot be reassigned.
 */
/**
 * @begin invalid-const-auto-reassign
 * @summary A const auto local cannot be reassigned.
 * @topic Negative
 */
void Test()
{
	const auto Value = 3;
	Value = 4;
}
/** @end */
