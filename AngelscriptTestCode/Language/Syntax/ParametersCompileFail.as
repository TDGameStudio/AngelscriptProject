/**
 * @version v1
 * @summary Compile-fail cases for Parameters.
 * @topic Language
 * @topic Syntax
 *
 * invalid-void-parameter                     // Void is not a legal parameter type.
 * invalid-function-unknown-parameter-type    // Compile-rejection form retained from legacy function unknown parameter type.
 * invalid-void-parameter-type                // Compile-rejection form retained from legacy void parameter type.
 */
/**
 * @begin invalid-void-parameter
 * @summary Void is not a legal parameter type.
 * @topic Negative
 */
void Bad(void Amount)
{
}
/** @end */
/**
 * @begin invalid-function-unknown-parameter-type
 * @summary Compile-rejection form retained from legacy function unknown parameter type.
 * @topic Negative
 */
void Foo(NonExistentType X)
{
}
/** @end */
/**
 * @begin invalid-void-parameter-type
 * @summary Compile-rejection form retained from legacy void parameter type.
 * @topic Negative
 */
void Foo(void X)
{
}
/** @end */
