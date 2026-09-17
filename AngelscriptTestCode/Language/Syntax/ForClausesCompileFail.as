/**
 * @version v1
 * @summary Compile-fail cases for ForClauses.
 * @topic Language
 * @topic Syntax
 *
 * invalid-for-without-parens
 * invalid-for-non-bool-condition
 * invalid-for-header-without-semicolons
 * invalid-for-without-parentheses
 * invalid-for-with-two-clauses-only
 */
/**
 * @begin invalid-for-without-parens
 * @summary A for header requires parentheses.
 * @topic Negative
 */
void Test()
{
	for int Index = 0; Index < 1; ++Index
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-for-non-bool-condition
 * @summary A for condition must be boolean.
 * @topic Negative
 */
void Test()
{
	for (int Index = 0; Index; ++Index)
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-for-header-without-semicolons
 * @summary Compile-rejection form retained from legacy for header without semicolons.
 * @topic Negative
 */
void Test()
{
	for (int I = 0 I < 10 ++I)
	{
	}
}
/** @end */
/**
 * @begin invalid-for-without-parentheses
 * @summary Compile-rejection form retained from legacy for without parentheses.
 * @topic Negative
 */
void Test()
{
	for int I = 0; I < 10; ++I
	{
	}
}
/** @end */
/**
 * @begin invalid-for-with-two-clauses-only
 * @summary Compile-rejection form retained from legacy for with two clauses only.
 * @topic Negative
 */
void Test()
{
	for (int I = 0; I < 10)
	{
	}
}
/** @end */
