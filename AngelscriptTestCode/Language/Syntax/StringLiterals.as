/**
 * @version v1
 * @summary Ordinary, escaped, concatenated, and live heredoc string literals.
 * @topic Language
 * @topic Syntax
 *
 * string-literal-assignment       // A string local assigned from a quoted literal.
 * empty-string-literal            // An empty quoted string assigned to a local.
 * string-escape-sequences         // Newline, tab, quote, and backslash escapes in a quoted string.
 * string-concat-in-declaration    // Adjacent quoted strings joined with plus in a declaration.
 * heredoc-string-literal          // A live triple-quoted heredoc assigned to a string local.
 */
/**
 * @begin string-literal-assignment
 * @summary A string local assigned from a quoted literal.
 */
string Literal()
{
	string Text = "Hello World";
	return Text;
}
/** @end */
/**
 * @begin empty-string-literal
 * @summary An empty quoted string assigned to a local.
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
 * @summary Newline, tab, quote, and backslash escapes in a quoted string.
 * @topic Syntax
 */
string Escapes()
{
	return "Line1\nLine2\t\"\\";
}
/** @end */
/**
 * @begin string-concat-in-declaration
 * @summary Adjacent quoted strings joined with plus in a declaration.
 * @topic Syntax
 */
string Combined()
{
	string Text = "Hello" + " World";
	return Text;
}
/** @end */
/**
 * @begin heredoc-string-literal
 * @summary A live triple-quoted heredoc assigned to a string local.
 * @topic Syntax
 */
string Heredoc()
{
	string Text = """
hello
world
""";
	return Text;
}
/** @end */
