/**
 * @version v1
 * @summary A ternary whose two branches have different types is rejected: both branches must produce the same type. This file is the illegal program itself; do not cast or drop either branch, since the mismatch is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A ternary whose two branches have different types is rejected: both branches must produce the same type. This file is the illegal program itself; do not cast or drop either branch, since the mismatch is the point.
 * @topic Negative
 */
/** */
void Test()
{
	auto X = true ? 1 : "hello";
}
/** @end */
