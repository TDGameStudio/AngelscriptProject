/**
 * @version v1
 * @summary A minimal integer-return function.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A function that returns a constant integer.
 * @topic Baseline
 */
int Answer()
{
	return 42;
}
/** @end */
/**
 * @version invalid-void-result-as-int
 * @parent root
 * @summary A void call cannot be returned as int.
 * @topic Negative
 */
void Work()
{
}

int Test()
{
	return Work();
}
/** @end */
/**
 * @version invalid-function-unknown-return-type
 * @parent root
 * @summary Compile-rejection form retained from legacy function unknown return type.
 * @topic Negative
 */
NonExistentType Foo()
{
}
/** @end */
/**
 * @version invalid-function-without-return-type
 * @parent root
 * @summary Compile-rejection form retained from legacy function without return type.
 * @topic Negative
 */
Foo()
{
}
/** @end */
/**
 * @version valid-int-return-function
 * @parent root
 * @summary A function whose only job is to return an integer literal.
 * @topic Syntax
 */
int Answer()
{
	return 42;
}
/** @end */
/**
 * @version invalid-return-missing-semicolon
 * @parent root
 * @summary A return expression must end with a semicolon.
 * @topic Negative
 */
int Test()
{
	return 1
}
/** @end */
