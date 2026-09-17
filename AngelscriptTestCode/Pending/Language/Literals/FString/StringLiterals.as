/**
 * @version v1
 * @summary String literal forms: basic, empty, escape sequences, Unicode, name literals, and long construction. Each helper returns one literal form so a failure names the exact escape or encoding that regressed.
 * @topic Language
 */
/**
 * @version root
 * @summary String literal forms: basic, empty, escape sequences, Unicode, name literals, and long construction. Each helper returns one literal form so a failure names the exact escape or encoding that regressed.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * A basic string literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello World"
	 */
	FString LiteralBasic()
	{
		return "Hello World";
	}

	/**
	 * An empty string literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return an empty string
	 */
	FString LiteralEmpty()
	{
		return "";
	}

	/**
	 * A literal containing a newline escape.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Line1\nLine2"
	 */
	FString LiteralNewline()
	{
		return "Line1\nLine2";
	}

	/**
	 * A literal containing a tab escape.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "A\tB"
	 */
	FString LiteralTab()
	{
		return "A\tB";
	}

	/**
	 * A literal containing escaped quote characters.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Say \"Hi\""
	 */
	FString LiteralQuote()
	{
		return "Say \"Hi\"";
	}

	/**
	 * A literal containing escaped backslashes.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "C:\\Path\\File"
	 */
	FString LiteralBackslash()
	{
		return "C:\\Path\\File";
	}

	/**
	 * A literal containing non-ASCII characters.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello 世界"
	 */
	FString LiteralUnicode()
	{
		return "Hello 世界";
	}

	/**
	 * A name literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return n"TestName"
	 */
	FName LiteralName()
	{
		return n"TestName";
	}

	/**
	 * Builds a long string by repeated concatenation.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return a string of 1100 'x' characters
	 */
	FString LiteralLong()
	{
		FString s = "";
		for (int i = 0; i < 1100; ++i)
		{
			s += "x";
		}
		return s;
	}

	/**
	 * Reports the length of the long constructed string.
	 *
	 * @Covers Literals.FString
	 * @Inputs LiteralLong()
	 * @Return the character count
	 */
	int LiteralLongLength()
	{
		return LiteralLong().Len();
	}

	/**
	 * Round-trips a literal through FText construction.
	 *
	 * @Covers Literals.FString
	 * @Inputs the literal "TextLiteral"
	 * @Return "TextLiteral"
	 */
	FString LiteralTextConstructor()
	{
		return FText::FromString("TextLiteral").ToString();
	}

	/**
	 * Observe that every literal form round-trips to its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all literal helpers
	 * @Return true when all eight outcomes match
	 */
	UFUNCTION()
	bool StringLiteralsProduceExpectedValues()
	{
		if (LiteralBasic() != "Hello World")
		{
			return false;
		}

		if (LiteralNewline() != "Line1\nLine2")
		{
			return false;
		}

		if (LiteralTab() != "A\tB")
		{
			return false;
		}

		if (LiteralQuote() != "Say \"Hi\"")
		{
			return false;
		}

		if (LiteralBackslash() != "C:\\Path\\File")
		{
			return false;
		}

		if (LiteralUnicode() != "Hello 世界")
		{
			return false;
		}

		if (LiteralName() != n"TestName")
		{
			return false;
		}

		return LiteralTextConstructor() == "TextLiteral";
	}

	/**
	 * Observe that the empty literal is empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs LiteralEmpty()
	 * @Return true when the value is empty
	 * @Boundary empty literal
	 */
	UFUNCTION()
	bool LiteralEmptyBoundary()
	{
		return LiteralEmpty() == "";
	}

	/**
	 * Observe the length boundary of the long constructed string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs LiteralLongLength()
	 * @Return true when the length is 1100
	 * @Boundary long string
	 */
	UFUNCTION()
	bool LiteralLongLengthBoundary()
	{
		return LiteralLongLength() == 1100;
	}
}
/** @end */
