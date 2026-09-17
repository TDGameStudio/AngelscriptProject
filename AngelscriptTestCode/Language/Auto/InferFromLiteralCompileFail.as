/**
 * @version v1
 * @summary Auto inference forms from literals that do not compile.
 * @topic Language
 * @topic Auto
 *
 * invalid-auto-without-initializer       // An auto local requires an initializer.
 * auto-reassign-wrong-type               // An auto int local cannot be assigned a string.
 * invalid-auto-bool-to-int               // An auto bool local cannot be assigned an int.
 * invalid-auto-float-to-bool             // An auto float local cannot be assigned a bool.
 * invalid-auto-reassign-string-to-int    // An auto string local cannot be assigned an int.
 * invalid-auto-bare-null                 // auto cannot infer a type from a bare nullptr.
 */
/**
 * @begin invalid-auto-without-initializer
 * @summary An auto local requires an initializer.
 * @topic Negative
 */
void Test()
{
	auto Value;
}
/** @end */
/**
 * @begin auto-reassign-wrong-type
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
 * @begin invalid-auto-bool-to-int
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
 * @begin invalid-auto-float-to-bool
 * @summary An auto float local cannot be assigned a bool.
 * @topic Negative
 */
void Test()
{
	auto Value = 1.5f;
	Value = false;
}
/** @end */
/**
 * @begin invalid-auto-reassign-string-to-int
 * @summary An auto string local cannot be assigned an int.
 * @topic Negative
 */
void Test()
{
	auto Text = "hello";
	Text = 1;
}
/** @end */
/**
 * @begin invalid-auto-bare-null
 * @summary auto cannot infer a type from a bare nullptr.
 * @topic Negative
 */
void Test()
{
	auto Value = nullptr;
}
/** @end */
