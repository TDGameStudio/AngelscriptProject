/**
 * @version v1
 * @summary An event whose parameter type is unknown is rejected. NonExistentType is not a declared script type, so the signature cannot be formed.
 * @topic Feature
 */
/**
 * @version root
 * @summary An event whose parameter type is unknown is rejected. NonExistentType is not a declared script type, so the signature cannot be formed.
 * @topic Negative
 */
/**
 * The isolated failing program: an event parameterized by an unknown type.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs NonExistentType X
 * @Return does not compile; the parameter type is undeclared
 */
event void FOnChangedBadParam(NonExistentType X);
/** @end */
