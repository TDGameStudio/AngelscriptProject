/**
 * @version v1
 * @summary Integer and float arithmetic forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Representative arithmetic helpers: binary ops, unary negation, increment, mixed types.
 * @topic Baseline
 */
int AddInt()
{
	return 1 + 2;
}

int SubInt()
{
	return 5 - 3;
}

int MulInt()
{
	return 2 * 3;
}

int DivInt()
{
	return 10 / 2;
}

int ModInt()
{
	return 10 % 3;
}

int AddFloat()
{
	float X = 1.0f + 2.5f;
	return int(X * 10);
}

int UnaryNeg()
{
	int X = 5;
	return -X;
}

int PreInc()
{
	int X = 0;
	++X;
	return X;
}

int PostInc()
{
	int X = 0;
	X++;
	return X;
}

int PreDec()
{
	int X = 5;
	--X;
	return X;
}

int PostDec()
{
	int X = 5;
	X--;
	return X;
}

int CompoundExpr()
{
	return (1 + 2) * 3 - 4 / 2 + 7 % 3;
}

int MixedTypes()
{
	float X = 1 + 2.0f;
	return int(X * 10);
}
/** @end */
/**
 * @version invalid-bool-addition
 * @parent root
 * @summary Boolean operands cannot use arithmetic plus.
 * @topic Negative
 */
void Test()
{
	bool A = true;
	bool B = false;
	int X = A + B;
}
/** @end */
/**
 * @version invalid-float-modulo
 * @parent root
 * @summary Float modulo is not a valid arithmetic form.
 * @topic Negative
 */
void Test()
{
	float X = 10.0f % 3.0f;
}
/** @end */
/**
 * @version invalid-increment-on-literal
 * @parent root
 * @summary Increment cannot target a literal.
 * @topic Negative
 */
void Test()
{
	++5;
}
/** @end */
/**
 * @version invalid-arithmetic-missing-right-operand
 * @parent root
 * @summary Compile-rejection form retained from legacy arithmetic missing right operand.
 * @topic Negative
 */
void Test()
{
	int X = 1 + ;
}
/** @end */
/**
 * @version invalid-assign-to-expression-result
 * @parent root
 * @summary Compile-rejection form retained from legacy assign to expression result.
 * @topic Negative
 */
void Test()
{
	int A = 1;
	int B = 2;
	(A + B) = 5;
}
/** @end */
/**
 * @version invalid-comma-expression-outside-for-clause
 * @parent root
 * @summary Compile-rejection form retained from legacy comma expression outside for clause.
 * @topic Negative
 */
int CommaExpression()
{
	int A = 1;
	int B = 2;
	int C = 3;
	int X = (A, B, C);
	return X;
}
/** @end */
/**
 * @version invalid-double-operator-in-expression
 * @parent root
 * @summary Compile-rejection form retained from legacy double operator in expression.
 * @topic Negative
 */
void Test()
{
	int X = 1 ++ 2;
}
/** @end */
/**
 * @version invalid-empty-parentheses-as-value
 * @parent root
 * @summary Compile-rejection form retained from legacy empty parentheses as value.
 * @topic Negative
 */
void Test()
{
	int X = ();
}
/** @end */
/**
 * @version invalid-increment-on-const
 * @parent root
 * @summary Compile-rejection form retained from legacy increment on const.
 * @topic Negative
 */
void Test()
{
	const int X = 5;
	++X;
}
/** @end */
/**
 * @version invalid-leading-binary-operator
 * @parent root
 * @summary Compile-rejection form retained from legacy leading binary operator.
 * @topic Negative
 */
void Test()
{
	int X = * 2;
}
/** @end */
/**
 * @version invalid-string-plus-int
 * @parent root
 * @summary Compile-rejection form retained from legacy string plus int.
 * @topic Negative
 */
void Test()
{
	int X = "hello" + 1;
}
/** @end */
/**
 * @version invalid-string-times-int
 * @parent root
 * @summary Compile-rejection form retained from legacy string times int.
 * @topic Negative
 */
void Test()
{
	auto S = "abc" * 3;
}
/** @end */
/**
 * @version invalid-trailing-operator
 * @parent root
 * @summary Compile-rejection form retained from legacy trailing operator.
 * @topic Negative
 */
void Test()
{
	int X = 1 +;
}
/** @end */
/**
 * @version invalid-unary-plus-on-string
 * @parent root
 * @summary Compile-rejection form retained from legacy unary plus on string.
 * @topic Negative
 */
void Test()
{
	string S = +"hello";
}
/** @end */
/**
 * @version valid-string-concatenation-plus
 * @parent root
 * @summary String concatenation with plus.
 * @topic Operators
 */
string Concat()
{
	return "Hello" + " " + "World";
}
/** @end */
/**
 * @version invalid-string-subtraction
 * @parent root
 * @summary Strings cannot use minus.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" - "b";
}
/** @end */
/**
 * @version invalid-string-multiplication
 * @parent root
 * @summary Strings cannot use times.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" * 2;
}
/** @end */
/**
 * @version invalid-string-division
 * @parent root
 * @summary Strings cannot use divide.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" / 2;
}
/** @end */
