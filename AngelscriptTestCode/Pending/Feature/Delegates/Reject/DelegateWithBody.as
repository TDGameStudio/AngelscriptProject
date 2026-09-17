/**
 * @version v1
 * @summary A delegate declaration with a function body is rejected. The signature is only a type; it does not carry an implementation.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate declaration with a function body is rejected. The signature is only a type; it does not carry an implementation.
 * @topic Negative
 */
/**
 * The isolated failing program: a delegate type with a body.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; delegate types have no body
 */
delegate void FOnActionBody()
{
}
/** @end */
