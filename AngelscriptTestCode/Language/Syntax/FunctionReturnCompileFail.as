/**
 * @version v1
 * @summary Compile-fail cases for FunctionReturn.
 * @topic Language
 * @topic Syntax
 *
 * invalid-void-result-as-int              // A void call cannot be returned as int.
 * invalid-function-unknown-return-type    // Compile-rejection form retained from legacy function unknown return type.
 * invalid-function-without-return-type    // Compile-rejection form retained from legacy function without return type.
 * invalid-return-missing-semicolon        // A return expression must end with a semicolon.
 */
/**
 * @begin invalid-void-result-as-int
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
 * @begin invalid-function-unknown-return-type
 * @summary Compile-rejection form retained from legacy function unknown return type.
 * @topic Negative
 */
NonExistentType Foo()
{
}
/** @end */
/**
 * @begin invalid-function-without-return-type
 * @summary Compile-rejection form retained from legacy function without return type.
 * @topic Negative
 */
Foo()
{
}
/** @end */
/**
 * @begin invalid-return-missing-semicolon
 * @summary A return expression must end with a semicolon.
 * @topic Negative
 */
int Test()
{
	return 1
}
/** @end */
