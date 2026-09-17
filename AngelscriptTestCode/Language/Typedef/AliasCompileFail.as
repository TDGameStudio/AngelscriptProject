/**
 * @version v1
 * @summary Typedef alias forms that do not compile.
 * @topic Language
 * @topic Typedef
 *
 * invalid-duplicate-typedef       // Reusing the same alias name is rejected.
 * invalid-typedef-without-name    // A typedef with no alias name is rejected.
 * invalid-typedef-unknown-type    // Aliasing an undeclared type is rejected.
 */
/**
 * @begin invalid-duplicate-typedef
 * @summary Reusing the same alias name is rejected.
 * @topic Negative
 */
typedef int Count;
typedef float Count;
/** @end */
/**
 * @begin invalid-typedef-without-name
 * @summary A typedef with no alias name is rejected.
 * @topic Negative
 */
typedef int;
/** @end */
/**
 * @begin invalid-typedef-unknown-type
 * @summary Aliasing an undeclared type is rejected.
 * @topic Negative
 */
typedef MissingType Alias;
/** @end */
