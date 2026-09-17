/**
 * @version v1
 * @summary Explicit numeric casts that must not compile.
 * @topic Language
 * @topic Casting
 *
 * invalid-explicit-unknown-type
 * invalid-explicit-multiple-arguments
 * invalid-explicit-string-to-int
 * invalid-explicit-to-void
 */
/**
 * @begin invalid-explicit-unknown-type
 * @summary An unknown target type cannot be used as a cast.
 * @topic Negative
 */
void Test()
{
	int X = NotAType(1);
}
/** @end */
/**
 * @begin invalid-explicit-multiple-arguments
 * @summary Compile-rejection form retained from legacy explicit multiple arguments.
 * @topic Negative
 */
void Test()
{
	int X = int(1, 2, 3);
}
/** @end */
/**
 * @begin invalid-explicit-string-to-int
 * @summary Compile-rejection form retained from legacy explicit string to int.
 * @topic Negative
 */
void Test()
{
	string S = "hello";
	int X = int(S);
}
/** @end */
/**
 * @begin invalid-explicit-to-void
 * @summary Compile-rejection form retained from legacy explicit to void.
 * @topic Negative
 */
void Test()
{
	int X = 5;
	void(X);
}
/** @end */
