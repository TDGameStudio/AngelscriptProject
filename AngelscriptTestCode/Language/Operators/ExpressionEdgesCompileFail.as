/**
 * @version v1
 * @summary Compile-fail cases for ExpressionEdges.
 * @topic Language
 * @topic Operators
 *
 * invalid-unmatched-paren
 * invalid-unmatched-parenthesis
 * invalid-extra-closing-paren
 * invalid-empty-call-on-int
 */
/**
 * @begin invalid-unmatched-paren
 * @summary An unmatched opening parenthesis is invalid.
 * @topic Negative
 */
int Test()
{
	return ((1 + 2);
}
/** @end */
/**
 * @begin invalid-unmatched-parenthesis
 * @summary Compile-rejection form retained from legacy unmatched parenthesis.
 * @topic Negative
 */
void Test()
{
	int X = (1 + 2;
}
/** @end */
/**
 * @begin invalid-extra-closing-paren
 * @summary An extra closing parenthesis is invalid.
 * @topic Negative
 */
int Test()
{
	return (1 + 2));
}
/** @end */
/**
 * @begin invalid-empty-call-on-int
 * @summary An integer cannot be called.
 * @topic Negative
 */
void Test()
{
	int Value = 1;
	Value();
}
/** @end */
