/**
 * @version v1
 * @summary A delegate declaration without a type name is rejected. The signature must name the type between the return type and the parameter list.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate declaration without a type name is rejected. The signature must name the type between the return type and the parameter list.
 * @topic Negative
 */
/**
 * The isolated failing program: a delegate with no type name.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; the type is unnamed
 */
delegate void ();
/** @end */
