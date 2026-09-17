/**
 * @version v1
 * @summary Auto infers a local type from an integer initializer.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary auto Value = 3 infers int and returns that value.
 * @topic Baseline
 */
int Inferred()
{
	auto Value = 3;
	return Value;
}
/** @end */
/**
 * @version valid-reassign-same-type
 * @parent root
 * @summary An auto int local can be reassigned another int.
 * @topic Auto
 */
int Reassigned()
{
	auto Value = 3;
	Value = 4;
	return Value;
}
/** @end */
/**
 * @version valid-auto-int-in-expression
 * @parent root
 * @summary An inferred int participates in arithmetic.
 * @topic Auto
 */
int Added()
{
	auto Value = 3;
	return Value + 1;
}
/** @end */
