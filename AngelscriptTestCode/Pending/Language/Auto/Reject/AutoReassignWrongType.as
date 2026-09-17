/**
 * @version v1
 * @summary Auto is monomorphic: the inferred type cannot change on later assignment.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary An auto int local cannot be assigned a string.
 * @topic Negative
 */
void Test()
{
	auto Value = 1;
	Value = "hello";
}
/** @end */
/**
 * @version invalid-auto-bool-to-int
 * @parent root
 * @summary An auto bool local cannot be assigned an int.
 * @topic Negative
 */
void Test()
{
	auto Flag = true;
	Flag = 1;
}
/** @end */
/**
 * @version invalid-auto-float-to-bool
 * @parent root
 * @summary An auto float local cannot be assigned a bool.
 * @topic Negative
 */
void Test()
{
	auto Value = 1.5f;
	Value = false;
}
/** @end */
