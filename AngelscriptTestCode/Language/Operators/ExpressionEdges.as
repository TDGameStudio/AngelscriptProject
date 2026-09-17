/**
 * @version v1
 * @summary Deep parentheses, long chains, and assignment-in-expression forms.
 * @topic Language
 * @topic Operators
 *
 * expression-edges
 * unary-minus-versus-subtract
 * deeply-nested-parens
 */
/**
 * @begin expression-edges
 * @summary Nested parentheses, a long addition chain, and assignment used as a statement sequence.
 */
int MaxParens()
{
	return ((((1 + 2))));
}

int LongChain()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
}

int PrecedenceMix()
{
	return 2 + 3 * 4 - 1;
}

int AssignThenRead()
{
	int X = 0;
	X = 5;
	int Y = X;
	return Y;
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
