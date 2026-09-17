/**
 * @version v1
 * @summary Assignment and compound assignment forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Plain assignment plus arithmetic, bitwise, and shift compound assignments.
 * @topic Baseline
 */
int SimpleAssign()
{
	int X = 0;
	X = 5;
	return X;
}

int AddAssign()
{
	int X = 0;
	X += 5;
	return X;
}

int SubAssign()
{
	int X = 10;
	X -= 3;
	return X;
}

int MulAssign()
{
	int X = 2;
	X *= 3;
	return X;
}

int DivAssign()
{
	int X = 10;
	X /= 2;
	return X;
}

int ModAssign()
{
	int X = 10;
	X %= 3;
	return X;
}

int BitAndAssign()
{
	int X = 255;
	X &= 15;
	return X;
}

int BitOrAssign()
{
	int X = 0;
	X |= 255;
	return X;
}

int BitXorAssign()
{
	int X = 255;
	X ^= 15;
	return X;
}

int ShiftLAssign()
{
	int X = 1;
	X <<= 4;
	return X;
}

int ShiftRAssign()
{
	int X = 16;
	X >>= 2;
	return X;
}
/** @end */
/**
 * @version invalid-assign-to-literal
 * @parent root
 * @summary A literal cannot be the target of assignment.
 * @topic Negative
 */
void Test()
{
	5 = 1;
}
/** @end */
/**
 * @version invalid-compound-on-const
 * @parent root
 * @summary A const local cannot be compound-assigned.
 * @topic Negative
 */
void Test()
{
	const int X = 1;
	X += 1;
}
/** @end */
/**
 * @version invalid-add-assign-string-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy add assign string to int.
 * @topic Negative
 */
void Test()
{
	int X = 0;
	X += "hello";
}
/** @end */
/**
 * @version invalid-assignment-to-const
 * @parent root
 * @summary Compile-rejection form retained from legacy assignment to const.
 * @topic Negative
 */
void Test()
{
	const int X = 5;
	X = 10;
}
/** @end */
/**
 * @version invalid-assignment-to-expression
 * @parent root
 * @summary Compile-rejection form retained from legacy assignment to expression.
 * @topic Negative
 */
void Test()
{
	int X = 0;
	int Y = 0;
	(X + Y) = 5;
}
/** @end */
/**
 * @version invalid-assignment-to-function-return
 * @parent root
 * @summary Compile-rejection form retained from legacy assignment to function return.
 * @topic Negative
 */
int Foo()
{
	return 1;
}

void Test()
{
	Foo() = 5;
}
/** @end */
/**
 * @version invalid-assignment-to-literal
 * @parent root
 * @summary Compile-rejection form retained from legacy assignment to literal.
 * @topic Negative
 */
void Test()
{
	5 = 10;
}
/** @end */
/**
 * @version invalid-assignment-to-undeclared-variable
 * @parent root
 * @summary Compile-rejection form retained from legacy assignment to undeclared variable.
 * @topic Negative
 */
void Test()
{
	UndeclaredVar = 5;
}
/** @end */
/**
 * @version invalid-mod-assign-on-float
 * @parent root
 * @summary Compile-rejection form retained from legacy mod assign on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f;
	X %= 2.0f;
}
/** @end */
/**
 * @version invalid-shift-assign-on-float
 * @parent root
 * @summary Compile-rejection form retained from legacy shift assign on float.
 * @topic Negative
 */
void Test()
{
	float X = 1.0f;
	X <<= 2;
}
/** @end */
/**
 * @version invalid-string-assigned-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy string assigned to int.
 * @topic Negative
 */
void Test()
{
	int X = 0;
	X = "hello";
}
/** @end */
/**
 * @version valid-string-concatenation-plus-assign
 * @parent root
 * @summary Plus-assign concatenates onto a string local.
 * @topic Operators
 */
string ConcatAssign()
{
	string Text = "Hello";
	Text += " World";
	return Text;
}
/** @end */
