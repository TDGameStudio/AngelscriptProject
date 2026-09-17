/**
 * @version v1
 * @summary Two delegate types with the same name are rejected. The second declaration cannot reuse FOnActionDup even with a different signature.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two delegate types with the same name are rejected. The second declaration cannot reuse FOnActionDup even with a different signature.
 * @topic Negative
 */
/**
 * The first FOnActionDup declaration.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return a void unicast with no parameters
 */
delegate void FOnActionDup();

/**
 * The isolated failing program: a second FOnActionDup with an int parameter.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs int X
 * @Return does not compile; the name is already taken
 */
delegate void FOnActionDup(int X);
/** @end */
