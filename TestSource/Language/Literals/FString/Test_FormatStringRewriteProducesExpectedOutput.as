// Theme: Language.Literals.FString. Positive f-string rewrite and execution.
// C++: AngelscriptCompilerFormatStringTests.cpp::FormatStringRewriteProducesExpectedOutput
// sha256=d024590a706f072402df714303371ffe949ea12e62a8730dbc1c64c9248d7919; lines 91-129.
// Oracle: Entry() == 1117 (1000+100+10+4+2+1).
// Extra: escaped braces alone score 1000; all specifier branches are independent.
// DefaultSafe. Source owns locals.

int Entry()
{
	float Value = 12.34f;
	int Score = 0;

	if (f"{{Alpha}}" == "{Alpha}")
	{
		Score += 1000;
	}

	if (f"{20 + 1}" == "21")
	{
		Score += 100;
	}

	if (f"{21 =}" == "21 = 21")
	{
		Score += 10;
	}

	if (f"{255 :#06x}" == "0x00ff")
	{
		Score += 4;
	}

	if (f"{Value :.1f}" == "12.3")
	{
		Score += 2;
	}

	if (f"{Value =:.1f}" == "Value = 12.3")
	{
		Score += 1;
	}

	return Score;
}

bool Observe_FormatString_Nominal()
{
	return Entry() == 1117;
}

int Observe_FormatString_EscapedBraceOnly()
{
	int Score = 0;
	if (f"{{Alpha}}" == "{Alpha}")
	{
		Score += 1000;
	}
	return Score;
}

int Observe_FormatString_RepeatBoundary()
{
	int First = Entry();
	int Second = Entry();
	return First == 1117 && Second == 1117 ? 1117 : 0;
}
