/**
 * @version v1
 * @summary Compile-fail cases for leftover event introducers.
 * @topic Language
 * @topic Event
 *
 * leftover-event-keyword              // The removed event keyword is not a callable introducer.
 * leftover-event-keyword-with-parameter // A leftover event introducer with a parameter is still rejected.
 */
/**
 * @begin leftover-event-keyword
 * @summary The removed event keyword is not a callable introducer.
 * @topic Negative
 */
event void FOnChanged();
/** @end */
/**
 * @begin leftover-event-keyword-with-parameter
 * @summary A leftover event introducer with a parameter is still rejected.
 * @topic Negative
 */
event void FOnValue(int Value);
/** @end */
