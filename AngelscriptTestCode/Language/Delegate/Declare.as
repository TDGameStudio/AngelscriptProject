/**
 * @version v1
 * @summary Live delegate callable-type declarations.
 * @topic Language
 * @topic Delegate
 *
 * declare-delegate                   // A named delegate with a non-void return and an empty parameter list.
 * declare-delegate-with-parameter    // A named delegate whose parameter list has one typed parameter.
 * declare-delegate-void              // A named delegate whose return type is void.
 */
/**
 * @begin declare-delegate
 * @summary A named delegate with a non-void return and an empty parameter list.
 * @topic Delegate
 */
delegate int FDeclareDelegate();
/** @end */
/**
 * @begin declare-delegate-with-parameter
 * @summary A named delegate whose parameter list has one typed parameter.
 * @topic Delegate
 */
delegate int FDeclareDelegateWithParameter(int Value);
/** @end */
/**
 * @begin declare-delegate-void
 * @summary A named delegate whose return type is void.
 * @topic Delegate
 */
delegate void FDeclareDelegateVoid();
/** @end */
