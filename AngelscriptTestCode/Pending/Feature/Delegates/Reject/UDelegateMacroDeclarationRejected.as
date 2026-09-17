/**
 * @version v1
 * @summary The UDELEGATE() macro spelling is rejected. AngelScript declares delegates with the `delegate` keyword, not the C++ UDELEGATE wrapper.
 * @topic Feature
 */
/**
 * @version root
 * @summary The UDELEGATE() macro spelling is rejected. AngelScript declares delegates with the `delegate` keyword, not the C++ UDELEGATE wrapper.
 * @topic Negative
 */
/**
 * The isolated failing program: UDELEGATE() is not a script specifier.
 *
 * @Kind CompileReject
 * @Covers Delegates.UDelegateMacro
 * @Inputs int Value
 * @Return does not compile; UDELEGATE is not an identifier here
 */
UDELEGATE()
delegate void FCoverageUnsupportedUDelegate(int Value);
/** @end */
