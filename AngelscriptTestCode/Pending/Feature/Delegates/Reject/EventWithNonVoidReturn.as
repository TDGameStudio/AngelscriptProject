/**
 * @version v1
 * @summary A multicast event with a non-void return is rejected. Events fan out to many listeners and cannot return a value.
 * @topic Feature
 */
/**
 * @version root
 * @summary A multicast event with a non-void return is rejected. Events fan out to many listeners and cannot return a value.
 * @topic Negative
 */
/**
 * The isolated failing program: a multicast event that returns int.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; events are void
 */
event int FOnChangedReturn();
/** @end */
