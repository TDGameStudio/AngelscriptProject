/**
 * @version v1
 * @summary Compile-fail cases for Variables.
 * @topic Language
 * @topic Syntax
 *
 * invalid-use-before-declaration            // A local cannot be read before its declaration.
 * invalid-duplicate-local                   // Two locals cannot share a name in one scope.
 * invalid-void-variable                     // Void is not a legal variable type.
 * invalid-const-without-initializer         // Compile-rejection form retained from legacy const without initializer.
 * invalid-duplicate-local-variable          // Compile-rejection form retained from legacy duplicate local variable.
 * invalid-identifier-starting-with-digit    // Compile-rejection form retained from legacy identifier starting with digit.
 * invalid-keyword-as-variable-name          // Compile-rejection form retained from legacy keyword as variable name.
 * invalid-undeclared-type                   // Compile-rejection form retained from legacy undeclared type.
 * invalid-unterminated-string-literal       // A string literal must close on the same line.
 */
/**
 * @begin invalid-use-before-declaration
 * @summary A local cannot be read before its declaration.
 * @topic Negative
 */
int Test()
{
	int Y = X;
	int X = 1;
	return Y;
}
/** @end */
/**
 * @begin invalid-duplicate-local
 * @summary Two locals cannot share a name in one scope.
 * @topic Negative
 */
int Test()
{
	int X = 1;
	int X = 2;
	return X;
}
/** @end */
/**
 * @begin invalid-void-variable
 * @summary Void is not a legal variable type.
 * @topic Negative
 */
void Test()
{
	void X;
}
/** @end */
/**
 * @begin invalid-const-without-initializer
 * @summary Compile-rejection form retained from legacy const without initializer.
 * @topic Negative
 */
void Test()
{
	const int X;
}
/** @end */
/**
 * @begin invalid-duplicate-local-variable
 * @summary Compile-rejection form retained from legacy duplicate local variable.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	int X = 2;
}
/** @end */
/**
 * @begin invalid-identifier-starting-with-digit
 * @summary Compile-rejection form retained from legacy identifier starting with digit.
 * @topic Negative
 */
void Test()
{
	int 123abc = 0;
}
/** @end */
/**
 * @begin invalid-keyword-as-variable-name
 * @summary Compile-rejection form retained from legacy keyword as variable name.
 * @topic Negative
 */
void Test()
{
	int class = 0;
}
/** @end */
/**
 * @begin invalid-undeclared-type
 * @summary Compile-rejection form retained from legacy undeclared type.
 * @topic Negative
 */
void Test()
{
	NonExistentType X;
}
/** @end */
/**
 * @begin invalid-unterminated-string-literal
 * @summary A string literal must close on the same line.
 * @topic Negative
 */
void Test()
{
	string Text = "unterminated;
}
/** @end */
