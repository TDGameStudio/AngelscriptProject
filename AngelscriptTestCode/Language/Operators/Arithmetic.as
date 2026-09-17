/**
 * @version v1
 * @summary Integer and float arithmetic forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * add-int                      // Integer addition of two literals.
 * sub-int                      // Integer subtraction of two literals.
 * mul-int                      // Integer multiplication of two literals.
 * div-int                      // Integer division of two literals.
 * mod-int                      // Integer remainder of two literals.
 * add-float                    // Float addition of two literals.
 * sub-float                    // Float subtraction of two literals.
 * mul-float                    // Float multiplication of two literals.
 * div-float                    // Float division of two literals.
 * unary-minus-int              // Unary minus applied to an integer local.
 * unary-plus-int               // Unary plus applied to an integer local.
 * power-int                    // Integer power using the live ** token.
 * prefix-increment             // Prefix increment of an integer local.
 * postfix-increment            // Postfix increment of an integer local.
 * prefix-decrement             // Prefix decrement of an integer local.
 * postfix-decrement            // Postfix decrement of an integer local.
 * string-concatenation-plus    // String concatenation with plus.
 */
/**
 * @begin add-int
 * @summary Integer addition of two literals.
 */
int AddInt()
{
	return 1 + 2;
}
/** @end */
/**
 * @begin sub-int
 * @summary Integer subtraction of two literals.
 * @topic Operators
 */
int SubInt()
{
	return 5 - 3;
}
/** @end */
/**
 * @begin mul-int
 * @summary Integer multiplication of two literals.
 * @topic Operators
 */
int MulInt()
{
	return 2 * 3;
}
/** @end */
/**
 * @begin div-int
 * @summary Integer division of two literals.
 * @topic Operators
 */
int DivInt()
{
	return 10 / 2;
}
/** @end */
/**
 * @begin mod-int
 * @summary Integer remainder of two literals.
 * @topic Operators
 */
int ModInt()
{
	return 10 % 3;
}
/** @end */
/**
 * @begin add-float
 * @summary Float addition of two literals.
 * @topic Operators
 */
float AddFloat()
{
	return 1.0f + 2.5f;
}
/** @end */
/**
 * @begin sub-float
 * @summary Float subtraction of two literals.
 * @topic Operators
 */
float SubFloat()
{
	return 5.5f - 2.0f;
}
/** @end */
/**
 * @begin mul-float
 * @summary Float multiplication of two literals.
 * @topic Operators
 */
float MulFloat()
{
	return 2.0f * 3.5f;
}
/** @end */
/**
 * @begin div-float
 * @summary Float division of two literals.
 * @topic Operators
 */
float DivFloat()
{
	return 10.0f / 4.0f;
}
/** @end */
/**
 * @begin unary-minus-int
 * @summary Unary minus applied to an integer local.
 * @topic Operators
 */
int UnaryMinusInt()
{
	int X = 5;
	return -X;
}
/** @end */
/**
 * @begin unary-plus-int
 * @summary Unary plus applied to an integer local.
 * @topic Operators
 */
int UnaryPlusInt()
{
	int X = 5;
	return +X;
}
/** @end */
/**
 * @begin power-int
 * @summary Integer power using the live ** token.
 * @topic Operators
 */
int PowerInt()
{
	return 2 ** 3;
}
/** @end */
/**
 * @begin prefix-increment
 * @summary Prefix increment of an integer local.
 * @topic Operators
 */
int PrefixIncrement()
{
	int X = 0;
	++X;
	return X;
}
/** @end */
/**
 * @begin postfix-increment
 * @summary Postfix increment of an integer local.
 * @topic Operators
 */
int PostfixIncrement()
{
	int X = 0;
	X++;
	return X;
}
/** @end */
/**
 * @begin prefix-decrement
 * @summary Prefix decrement of an integer local.
 * @topic Operators
 */
int PrefixDecrement()
{
	int X = 5;
	--X;
	return X;
}
/** @end */
/**
 * @begin postfix-decrement
 * @summary Postfix decrement of an integer local.
 * @topic Operators
 */
int PostfixDecrement()
{
	int X = 5;
	X--;
	return X;
}
/** @end */
/**
 * @begin string-concatenation-plus
 * @summary String concatenation with plus.
 * @topic Operators
 */
string Concat()
{
	return "Hello" + " " + "World";
}
/** @end */
