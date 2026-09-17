/**
 * @version v1
 * @summary Auto cannot infer a type from a void expression.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary auto X = NoValue() is rejected because the callee returns void.
 * @topic Negative
 */
void NoValue()
{
}

void Test()
{
	auto X = NoValue();
}
/** @end */
/**
 * @version invalid-auto-void-type
 * @parent root
 * @summary Void is not a legal auto initializer type name.
 * @topic Negative
 */
void Test()
{
	auto X = void;
}
/** @end */
