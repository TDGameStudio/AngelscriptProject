/**
 * @version v1
 * @summary Compile-fail cases for Ternary.
 * @topic Language
 * @topic Operators
 *
 * invalid-ternary-non-bool-condition
 * invalid-ternary-mismatched-arms
 * invalid-ternary-branch-type-mismatch
 * invalid-ternary-float-condition
 * invalid-ternary-missing-colon
 * invalid-ternary-missing-true-branch
 * invalid-ternary-string-condition
 */
/**
 * @begin invalid-ternary-non-bool-condition
 * @summary The ternary condition must be boolean.
 * @topic Negative
 */
int Test()
{
	return 1 ? 2 : 3;
}
/** @end */
/**
 * @begin invalid-ternary-mismatched-arms
 * @summary Ternary arms must share a common type.
 * @topic Negative
 */
void Test(bool Flag)
{
	int X = Flag ? 1 : true;
}
/** @end */
/**
 * @begin invalid-ternary-branch-type-mismatch
 * @summary Compile-rejection form retained from legacy ternary branch type mismatch.
 * @topic Negative
 */
void Test()
{
	auto X = true ? 1 : "hello";
}
/** @end */
/**
 * @begin invalid-ternary-float-condition
 * @summary Compile-rejection form retained from legacy ternary float condition.
 * @topic Negative
 */
void Test()
{
	int X = 1.0f ? 1 : 0;
}
/** @end */
/**
 * @begin invalid-ternary-missing-colon
 * @summary Compile-rejection form retained from legacy ternary missing colon.
 * @topic Negative
 */
void Test()
{
	int X = true ? 1;
}
/** @end */
/**
 * @begin invalid-ternary-missing-true-branch
 * @summary Compile-rejection form retained from legacy ternary missing true branch.
 * @topic Negative
 */
void Test()
{
	int X = true ? : 0;
}
/** @end */
/**
 * @begin invalid-ternary-string-condition
 * @summary Compile-rejection form retained from legacy ternary string condition.
 * @topic Negative
 */
void Test()
{
	int X = "yes" ? 1 : 0;
}
/** @end */
