/**
 * @version v1
 * @summary A delegate whose parameter type is unknown is rejected. NonExistentType is not a declared script type, so the signature cannot be formed.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate whose parameter type is unknown is rejected. NonExistentType is not a declared script type, so the signature cannot be formed.
 * @topic Negative
 */
/**
 * The isolated failing program: a delegate parameterized by an unknown type.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs NonExistentType X
 * @Return does not compile; the parameter type is undeclared
 */
delegate void FOnActionBadParam(NonExistentType X);
/** @end */
