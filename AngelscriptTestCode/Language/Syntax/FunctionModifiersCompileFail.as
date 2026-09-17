/**
 * @version v1
 * @summary Compile-fail cases for FunctionModifiers.
 * @topic Language
 * @topic Syntax
 *
 * invalid-local-on-class-method     // The local prefix is not valid on a class method.
 * invalid-access-at-global-scope    // An access policy declaration is rejected outside a record.
 */
/**
 * @begin invalid-local-on-class-method
 * @summary The local prefix is not valid on a class method.
 * @topic Negative
 */
class AItem
{
	local int Read()
	{
		return 1;
	}
}
/** @end */
/**
 * @begin invalid-access-at-global-scope
 * @summary An access policy declaration is rejected outside a record.
 * @topic Negative
 */
access Friends = private;
/** @end */
