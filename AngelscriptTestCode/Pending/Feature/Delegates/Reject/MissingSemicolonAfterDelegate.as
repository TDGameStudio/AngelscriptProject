/**
 * @version v1
 * @summary A delegate declaration that omits the terminating semicolon is rejected. The signature must end with `;` rather than being left open.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate declaration that omits the terminating semicolon is rejected. The signature must end with `;` rather than being left open.
 * @topic Negative
 */
/**
 * The isolated failing program: a delegate signature with no semicolon.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; the declaration is not terminated
 */
delegate void FOnActionNoSemi()
/** @end */
