/**
 * @version v1
 * @summary Integer and float arithmetic forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * arithmetic
 * string-concatenation-plus
 */
/**
 * @begin arithmetic
 * @summary Representative arithmetic helpers: binary ops, unary negation, increment, mixed types.
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
 * @begin string-concatenation-plus
 * @summary String concatenation with plus.
 * @topic Operators
 */
string Concat()
{
	return "Hello" + " " + "World";
}
/** @end */
