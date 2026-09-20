/**
 * @version v1
 * @summary DECLARE-based delegate callable-type declarations.
 * @topic Language
 * @topic Delegate
 *
 * declare-delegate                   // An ordinary RetVal delegate with an empty parameter list.
 * declare-delegate-with-parameter    // An ordinary RetVal OneParam delegate.
 * declare-delegate-void              // An ordinary void delegate with no parameters.
 */
/**
 * @begin declare-delegate
 * @summary An ordinary RetVal delegate with an empty parameter list.
 * @topic Delegate
 */
DECLARE_DELEGATE_RetVal(int, FDeclareDelegate);
/** @end */
/**
 * @begin declare-delegate-with-parameter
 * @summary An ordinary RetVal OneParam delegate.
 * @topic Delegate
 */
DECLARE_DELEGATE_RetVal_OneParam(int, FDeclareDelegateWithParameter, int);
/** @end */
/**
 * @begin declare-delegate-void
 * @summary An ordinary void delegate with no parameters.
 * @topic Delegate
 */
DECLARE_DELEGATE(FDeclareDelegateVoid);
/** @end */
