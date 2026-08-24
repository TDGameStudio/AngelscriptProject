// Theme: Language.Literals.FString. Positive literals, escapes, Unicode, n"", FText.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::StringLiterals
// sha256 from TS-LANG-0128; lines 361-421.
// Oracle: Hello World; empty; newline/tab/quote/backslash; Hello 世界; n"TestName"; length 1100; TextLiteral.
// Extra: empty literal; long construction length boundary 1100.
// DefaultSafe. Source owns locals.

FString LiteralBasic()
{
	return "Hello World";
}

FString LiteralEmpty()
{
	return "";
}

FString LiteralNewline()
{
	return "Line1\nLine2";
}

FString LiteralTab()
{
	return "A\tB";
}

FString LiteralQuote()
{
	return "Say \"Hi\"";
}

FString LiteralBackslash()
{
	return "C:\\Path\\File";
}

FString LiteralUnicode()
{
	return "Hello 世界";
}

FName LiteralName()
{
	return n"TestName";
}

FString LiteralLong()
{
	FString s = "";
	for (int i = 0; i < 1100; ++i)
	{
		s += "x";
	}
	return s;
}

int LiteralLongLength()
{
	return LiteralLong().Len();
}

FString LiteralTextConstructor()
{
	return FText::FromString("TextLiteral").ToString();
}

bool Observe_StringLiterals_Nominal()
{
	return LiteralBasic() == "Hello World"
		&& LiteralNewline() == "Line1\nLine2"
		&& LiteralTab() == "A\tB"
		&& LiteralQuote() == "Say \"Hi\""
		&& LiteralBackslash() == "C:\\Path\\File"
		&& LiteralUnicode() == "Hello 世界"
		&& LiteralName() == n"TestName"
		&& LiteralTextConstructor() == "TextLiteral";
}

bool Observe_StringLiterals_EmptyDefault()
{
	return LiteralEmpty() == "";
}

bool Observe_LiteralLong_LengthBoundary()
{
	return LiteralLongLength() == 1100;
}
