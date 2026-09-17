/**
 * @version v1
 * @summary Auto infers a local type from a bool initializer.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary auto Flag = true infers bool and returns that value.
 * @topic Baseline
 */
bool Inferred()
{
	auto Flag = true;
	return Flag;
}
/** @end */
/**
 * @version valid-infer-false
 * @parent root
 * @summary Auto infers bool from a false initializer.
 * @topic Auto
 */
bool InferredFalse()
{
	auto Flag = false;
	return Flag;
}
/** @end */
/**
 * @version valid-reassign-same-type
 * @parent root
 * @summary An auto bool local can be reassigned another bool.
 * @topic Auto
 */
bool Reassigned()
{
	auto Flag = true;
	Flag = false;
	return Flag;
}
/** @end */
