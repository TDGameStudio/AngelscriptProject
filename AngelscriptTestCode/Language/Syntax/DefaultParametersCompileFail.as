/**
 * @version v1
 * @summary Compile-fail cases for DefaultParameters.
 * @topic Language
 * @topic Syntax
 *
 * invalid-default-before-required
 * invalid-default-type-mismatch
 * invalid-default-outside-class-scope
 * invalid-non-default-parameter-after-default
 */
/**
 * @begin invalid-default-before-required
 * @summary A required parameter cannot follow a defaulted one.
 * @topic Negative
 */
int Bad(int Count = 1, int Extra)
{
	return Count + Extra;
}
/** @end */
/**
 * @begin invalid-default-type-mismatch
 * @summary A default expression must match the parameter type.
 * @topic Negative
 */
int Bad(int Count = true)
{
	return Count;
}
/** @end */
/**
 * @begin invalid-default-outside-class-scope
 * @summary Compile-rejection form retained from legacy default outside class scope.
 * @topic Negative
 */
int GlobalValue = 5;
default GlobalValue = 10;
/** @end */
/**
 * @begin invalid-non-default-parameter-after-default
 * @summary Compile-rejection form retained from legacy non default parameter after default.
 * @topic Negative
 */
void Foo(int X = 5, int Y)
{
}
/** @end */
