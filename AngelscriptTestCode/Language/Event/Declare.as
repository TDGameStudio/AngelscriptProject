/**
 * @version v1
 * @summary DECLARE-based multicast event callable-type declarations.
 * @topic Language
 * @topic Event
 *
 * declare-event                   // An ordinary multicast delegate with an empty parameter list.
 * declare-event-with-parameter    // An ordinary multicast OneParam delegate.
 */
/**
 * @begin declare-event
 * @summary An ordinary multicast delegate with an empty parameter list.
 * @topic Event
 */
DECLARE_MULTICAST_DELEGATE(FDeclareEvent);
/** @end */
/**
 * @begin declare-event-with-parameter
 * @summary An ordinary multicast OneParam delegate.
 * @topic Event
 */
DECLARE_MULTICAST_DELEGATE_OneParam(FDeclareEventWithParameter, int);
/** @end */
