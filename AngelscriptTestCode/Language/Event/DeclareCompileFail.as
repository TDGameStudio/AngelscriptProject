/**
 * @version v1
 * @summary Compile-fail cases for live event callable-type declarations.
 * @topic Language
 * @topic Event
 *
 * invalid-event-without-name         // An event declaration requires a name after the return type.
 * invalid-event-missing-semicolon    // An event declaration must end with a semicolon.
 */
/**
 * @begin invalid-event-without-name
 * @summary An event declaration requires a name after the return type.
 * @topic Negative
 */
event void ();
/** @end */
/**
 * @begin invalid-event-missing-semicolon
 * @summary An event declaration must end with a semicolon.
 * @topic Negative
 */
event void FMissingSemicolon()
/** @end */
