/**
 * @version v1
 * @summary Compile-fail cases for Arithmetic.
 * @topic Language
 * @topic Operators
 *
 * invalid-bool-addition                          // Boolean operands cannot use arithmetic plus.
 * invalid-float-modulo                           // Float modulo is not a valid arithmetic form.
 * invalid-increment-on-literal                   // Increment cannot target a literal.
 * invalid-arithmetic-missing-right-operand       // Compile-rejection form retained from legacy arithmetic missing right operand.
 * invalid-assign-to-expression-result            // Compile-rejection form retained from legacy assign to expression result.
 * invalid-comma-expression-outside-for-clause    // Compile-rejection form retained from legacy comma expression outside for clause.
 * invalid-double-operator-in-expression          // Compile-rejection form retained from legacy double operator in expression.
 * invalid-empty-parentheses-as-value             // Compile-rejection form retained from legacy empty parentheses as value.
 * invalid-increment-on-const                     // Compile-rejection form retained from legacy increment on const.
 * invalid-leading-binary-operator                // Compile-rejection form retained from legacy leading binary operator.
 * invalid-string-plus-int                        // Compile-rejection form retained from legacy string plus int.
 * invalid-string-times-int                       // Compile-rejection form retained from legacy string times int.
 * invalid-trailing-operator                      // Compile-rejection form retained from legacy trailing operator.
 * invalid-unary-plus-on-string                   // Compile-rejection form retained from legacy unary plus on string.
 * invalid-string-subtraction                     // Strings cannot use minus.
 * invalid-string-multiplication                  // Strings cannot use times.
 * invalid-string-division                        // Strings cannot use divide.
 */
/**
 * @begin invalid-bool-addition
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
 * @begin invalid-float-modulo
 * @summary Float modulo is not a valid arithmetic form.
 * @topic Negative
 */
void Test()
{
	float X = 10.0f % 3.0f;
}
/** @end */
/**
 * @begin invalid-increment-on-literal
 * @summary Increment cannot target a literal.
 * @topic Negative
 */
void Test()
{
	++5;
}
/** @end */
/**
 * @begin invalid-arithmetic-missing-right-operand
 * @summary Compile-rejection form retained from legacy arithmetic missing right operand.
 * @topic Negative
 */
void Test()
{
	int X = 1 + ;
}
/** @end */
/**
 * @begin invalid-assign-to-expression-result
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
 * @begin invalid-comma-expression-outside-for-clause
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
 * @begin invalid-double-operator-in-expression
 * @summary Compile-rejection form retained from legacy double operator in expression.
 * @topic Negative
 */
void Test()
{
	int X = 1 ++ 2;
}
/** @end */
/**
 * @begin invalid-empty-parentheses-as-value
 * @summary Compile-rejection form retained from legacy empty parentheses as value.
 * @topic Negative
 */
void Test()
{
	int X = ();
}
/** @end */
/**
 * @begin invalid-increment-on-const
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
 * @begin invalid-leading-binary-operator
 * @summary Compile-rejection form retained from legacy leading binary operator.
 * @topic Negative
 */
void Test()
{
	int X = * 2;
}
/** @end */
/**
 * @begin invalid-string-plus-int
 * @summary Compile-rejection form retained from legacy string plus int.
 * @topic Negative
 */
void Test()
{
	int X = "hello" + 1;
}
/** @end */
/**
 * @begin invalid-string-times-int
 * @summary Compile-rejection form retained from legacy string times int.
 * @topic Negative
 */
void Test()
{
	auto S = "abc" * 3;
}
/** @end */
/**
 * @begin invalid-trailing-operator
 * @summary Compile-rejection form retained from legacy trailing operator.
 * @topic Negative
 */
void Test()
{
	int X = 1 +;
}
/** @end */
/**
 * @begin invalid-unary-plus-on-string
 * @summary Compile-rejection form retained from legacy unary plus on string.
 * @topic Negative
 */
void Test()
{
	string S = +"hello";
}
/** @end */
/**
 * @begin invalid-string-subtraction
 * @summary Strings cannot use minus.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" - "b";
}
/** @end */
/**
 * @begin invalid-string-multiplication
 * @summary Strings cannot use times.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" * 2;
}
/** @end */
/**
 * @begin invalid-string-division
 * @summary Strings cannot use divide.
 * @topic Negative
 */
void Test()
{
	string Text = "ab" / 2;
}
/** @end */
