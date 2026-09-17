/**
 * @version v1
 * @summary A typedef source type must already exist.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary Aliasing int is legal.
 * @topic Baseline
 */
typedef int Count;
/** @end */
/**
 * @version invalid-typedef-unknown-type
 * @parent root
 * @summary Aliasing an undeclared type is rejected.
 * @topic Negative
 */
typedef MissingType Alias;
/** @end */
