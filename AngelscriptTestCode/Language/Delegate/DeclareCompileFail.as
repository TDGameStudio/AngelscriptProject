/**
 * @version v1
 * @summary Compile-fail cases for leftover delegate introducers.
 * @topic Language
 * @topic Delegate
 *
 * leftover-delegate-keyword              // The removed delegate keyword is not a callable introducer.
 * leftover-delegate-keyword-with-parameter // A leftover delegate introducer with a parameter is still rejected.
 */
/**
 * @begin leftover-delegate-keyword
 * @summary The removed delegate keyword is not a callable introducer.
 * @topic Negative
 */
delegate int FOnDone();
/** @end */
/**
 * @begin leftover-delegate-keyword-with-parameter
 * @summary A leftover delegate introducer with a parameter is still rejected.
 * @topic Negative
 */
delegate int FOnChanged(int Value);
/** @end */
