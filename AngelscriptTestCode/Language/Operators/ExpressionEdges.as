/**
 * @version v1
 * @summary Deep parentheses, long chains, and assignment-in-expression forms.
 * @topic Language
 * @topic Operators
 *
 * expression-edges               // A long addition chain used as a single expression.
 * unary-minus-versus-subtract    // Unary minus on the right operand of subtraction.
 * deeply-nested-parens           // Eight nested parenthesis pairs around an addition.
 * parenthesized-primary          // A parenthesized primary expression.
 */
/**
 * @begin expression-edges
 * @summary A long addition chain used as a single expression.
 */
int LongChain()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
}
/** @end */
/**
 * @begin unary-minus-versus-subtract
 * @summary Unary minus on the right operand of subtraction.
 * @topic Operators
 */
int UnaryMinusRight()
{
	int Value = 5;
	return 3 - -Value;
}
/** @end */
/**
 * @begin deeply-nested-parens
 * @summary Eight nested parenthesis pairs around an addition.
 * @topic Operators
 */
int DeepParens()
{
	return ((((((((1 + 2))))))));
}
/** @end */
/**
 * @begin parenthesized-primary
 * @summary A parenthesized primary expression.
 * @topic Operators
 */
int ParenthesizedPrimary()
{
	int Value = 4;
	return (Value);
}
/** @end */
