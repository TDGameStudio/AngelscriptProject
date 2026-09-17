/**
 * @version v1
 * @summary Auto infers a local type from a float initializer.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary auto Value = 1.5f infers float and returns that value.
 * @topic Baseline
 */
float Inferred()
{
	auto Value = 1.5f;
	return Value;
}
/** @end */
/**
 * @version valid-reassign-same-type
 * @parent root
 * @summary An auto float local can be reassigned another float.
 * @topic Auto
 */
float Reassigned()
{
	auto Value = 1.5f;
	Value = 2.5f;
	return Value;
}
/** @end */
/**
 * @version valid-auto-float-zero
 * @parent root
 * @summary Auto infers float from a 0.0f initializer.
 * @topic Auto
 */
float Zero()
{
	auto Value = 0.0f;
	return Value;
}
/** @end */
