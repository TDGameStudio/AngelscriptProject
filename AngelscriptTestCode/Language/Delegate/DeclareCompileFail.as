/**
 * @version v1
 * @summary Compile-fail cases for live delegate callable-type declarations.
 * @topic Language
 * @topic Delegate
 *
 * invalid-delegate-without-name         // A delegate declaration requires a name after the return type.
 * invalid-delegate-missing-semicolon    // A delegate declaration must end with a semicolon.
 */
/**
 * @begin invalid-delegate-without-name
 * @summary A delegate declaration requires a name after the return type.
 * @topic Negative
 */
delegate int ();
/** @end */
/**
 * @begin invalid-delegate-missing-semicolon
 * @summary A delegate declaration must end with a semicolon.
 * @topic Negative
 */
delegate int FMissingSemicolon()
/** @end */
