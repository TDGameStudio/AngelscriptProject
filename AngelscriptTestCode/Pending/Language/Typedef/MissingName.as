/**
 * @version v1
 * @summary A typedef requires an alias identifier.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary typedef int Count names the alias.
 * @topic Baseline
 */
typedef int Count;
/** @end */
/**
 * @version invalid-typedef-without-name
 * @parent root
 * @summary A typedef with no alias name is rejected.
 * @topic Negative
 */
typedef int;
/** @end */
