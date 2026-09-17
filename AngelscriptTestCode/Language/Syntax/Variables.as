/**
 * @version v1
 * @summary Primitive locals, references, and block-scoped variables.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary Typed locals, a reference alias, and an inner-block variable.
 * @topic Baseline
 */
int PrimitiveLocals()
{
	int Count = 1;
	float Scale = 2.0f;
	bool Flag = true;
	int Total = Count + int(Scale);
	if (Flag)
	{
		int Inner = 3;
		Total += Inner;
	}
	return Total;
}

int ReferenceLocal()
{
	int Value = 1;
	int& Alias = Value;
	Alias = 4;
	return Value;
}
/** @end */
/**
 * @version invalid-use-before-declaration
 * @parent root
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
 * @version invalid-duplicate-local
 * @parent root
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
 * @version invalid-void-variable
 * @parent root
 * @summary Void is not a legal variable type.
 * @topic Negative
 */
void Test()
{
	void X;
}
/** @end */
/**
 * @version invalid-auto-without-initializer
 * @parent root
 * @summary Compile-rejection form retained from legacy auto without initializer.
 * @topic Negative
 */
void Test()
{
	auto X;
}
/** @end */
/**
 * @version invalid-const-without-initializer
 * @parent root
 * @summary Compile-rejection form retained from legacy const without initializer.
 * @topic Negative
 */
void Test()
{
	const int X;
}
/** @end */
/**
 * @version invalid-duplicate-local-variable
 * @parent root
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
 * @version invalid-identifier-starting-with-digit
 * @parent root
 * @summary Compile-rejection form retained from legacy identifier starting with digit.
 * @topic Negative
 */
void Test()
{
	int 123abc = 0;
}
/** @end */
/**
 * @version invalid-keyword-as-variable-name
 * @parent root
 * @summary Compile-rejection form retained from legacy keyword as variable name.
 * @topic Negative
 */
void Test()
{
	int class = 0;
}
/** @end */
/**
 * @version invalid-undeclared-type
 * @parent root
 * @summary Compile-rejection form retained from legacy undeclared type.
 * @topic Negative
 */
void Test()
{
	NonExistentType X;
}
/** @end */
/**
 * @version valid-string-literal-assignment
 * @parent root
 * @summary A string local assigned from a literal.
 * @topic Syntax
 */
string Literal()
{
	string Text = "Hello World";
	return Text;
}
/** @end */
/**
 * @version valid-empty-string-literal
 * @parent root
 * @summary An empty string literal assigned to a local.
 * @topic Syntax
 */
string Empty()
{
	string Text = "";
	return Text;
}
/** @end */
/**
 * @version valid-string-escape-sequences
 * @parent root
 * @summary Newline, tab, quote, and backslash escapes in a string literal.
 * @topic Syntax
 */
string Escapes()
{
	return "Line1\nLine2\t\"\\";
}
/** @end */
/**
 * @version invalid-unterminated-string-literal
 * @parent root
 * @summary A string literal must close on the same line.
 * @topic Negative
 */
void Test()
{
	string Text = "unterminated;
}
/** @end */
