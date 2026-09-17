/**
 * @version v1
 * @summary Deep parentheses, long chains, and assignment-in-expression forms.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Nested parentheses, a long addition chain, and assignment used as a statement sequence.
 * @topic Baseline
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
 * @version invalid-unmatched-paren
 * @parent root
 * @summary An unmatched opening parenthesis is invalid.
 * @topic Negative
 */
int Test()
{
	return ((1 + 2);
}
/** @end */
/**
 * @version invalid-unmatched-parenthesis
 * @parent root
 * @summary Compile-rejection form retained from legacy unmatched parenthesis.
 * @topic Negative
 */
void Test()
{
	int X = (1 + 2;
}
/** @end */
/**
 * @version valid-unary-minus-versus-subtract
 * @parent root
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
 * @version valid-deeply-nested-parens
 * @parent root
 * @summary Eight nested parenthesis pairs around an addition.
 * @topic Operators
 */
int DeepParens()
{
	return ((((((((1 + 2))))))));
}
/** @end */
/**
 * @version invalid-extra-closing-paren
 * @parent root
 * @summary An extra closing parenthesis is invalid.
 * @topic Negative
 */
int Test()
{
	return (1 + 2));
}
/** @end */
/**
 * @version invalid-empty-call-on-int
 * @parent root
 * @summary An integer cannot be called.
 * @topic Negative
 */
void Test()
{
	int Value = 1;
	Value();
}
/** @end */
