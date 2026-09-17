/**
 * @version v1
 * @summary Compile-fail cases for Assignment.
 * @topic Language
 * @topic Operators
 *
 * invalid-assign-to-literal
 * invalid-compound-on-const
 * invalid-add-assign-string-to-int
 * invalid-assignment-to-const
 * invalid-assignment-to-expression
 * invalid-assignment-to-function-return
 * invalid-assignment-to-literal
 * invalid-assignment-to-undeclared-variable
 * invalid-mod-assign-on-float
 * invalid-shift-assign-on-float
 * invalid-string-assigned-to-int
 */
/**
 * @begin invalid-assign-to-literal
 * @summary A literal cannot be the target of assignment.
 * @topic Negative
 */
void Test()
{
	5 = 1;
}
/** @end */
/**
 * @begin invalid-compound-on-const
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
 * @begin invalid-add-assign-string-to-int
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
 * @begin invalid-assignment-to-const
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
 * @begin invalid-assignment-to-expression
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
 * @begin invalid-assignment-to-function-return
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
 * @begin invalid-assignment-to-literal
 * @summary Compile-rejection form retained from legacy assignment to literal.
 * @topic Negative
 */
void Test()
{
	5 = 10;
}
/** @end */
/**
 * @begin invalid-assignment-to-undeclared-variable
 * @summary Compile-rejection form retained from legacy assignment to undeclared variable.
 * @topic Negative
 */
void Test()
{
	UndeclaredVar = 5;
}
/** @end */
/**
 * @begin invalid-mod-assign-on-float
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
 * @begin invalid-shift-assign-on-float
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
 * @begin invalid-string-assigned-to-int
 * @summary Compile-rejection form retained from legacy string assigned to int.
 * @topic Negative
 */
void Test()
{
	int X = 0;
	X = "hello";
}
/** @end */
