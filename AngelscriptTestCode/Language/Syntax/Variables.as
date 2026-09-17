/**
 * @version v1
 * @summary Primitive locals, references, and block-scoped variables.
 * @topic Language
 * @topic Syntax
 *
 * variables
 * string-literal-assignment
 * empty-string-literal
 * string-escape-sequences
 */
/**
 * @begin variables
 * @summary Typed locals, a reference alias, and an inner-block variable.
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
 * @begin string-literal-assignment
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
 * @begin empty-string-literal
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
 * @begin string-escape-sequences
 * @summary Newline, tab, quote, and backslash escapes in a string literal.
 * @topic Syntax
 */
string Escapes()
{
	return "Line1\nLine2\t\"\\";
}
/** @end */
