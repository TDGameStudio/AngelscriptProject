// Theme: Language.Literals.FString. Positive TrimStart/End/Char/Quotes.
// C++: AngelscriptCoverageFStringMethodTests.cpp::TrimMethods
// sha256 from TS-LANG-0152; lines 325-371.
// Oracle: Hello; Hello; Hello; Hello; **Hello**; Quoted; Plain.
// Extra: already-trimmed TrimNone; empty TrimStartAndEnd stays empty.
// DefaultSafe. Source owns locals.

FString TestTrimStart()
{
	FString s = "   Hello";
	return s.TrimStart();
}

FString TestTrimEnd()
{
	FString s = "Hello   ";
	return s.TrimEnd();
}

FString TestTrimStartAndEnd()
{
	FString s = "   Hello   ";
	return s.TrimStartAndEnd();
}

FString TestTrimNone()
{
	FString s = "Hello";
	return s.TrimStartAndEnd();
}

FString TestTrimChar()
{
	FString s = "***Hello***";
	return s.TrimChar(0x2A);
}

FString TestTrimQuotes()
{
	FString s = "\"Quoted\"";
	bool bQuotesRemoved = false;
	FString Result = s.TrimQuotes(bQuotesRemoved);
	return bQuotesRemoved ? Result : "failed";
}

FString TestTrimQuotesUnchanged()
{
	FString s = "Plain";
	bool bQuotesRemoved = false;
	FString Result = s.TrimQuotes(bQuotesRemoved);
	return bQuotesRemoved ? "failed" : Result;
}

bool Observe_TrimMethods_Nominal()
{
	return TestTrimStart() == "Hello"
		&& TestTrimEnd() == "Hello"
		&& TestTrimStartAndEnd() == "Hello"
		&& TestTrimNone() == "Hello"
		&& TestTrimChar() == "**Hello**"
		&& TestTrimQuotes() == "Quoted"
		&& TestTrimQuotesUnchanged() == "Plain";
}

FString Observe_Trim_EmptyDefault()
{
	FString Empty;
	return Empty.TrimStartAndEnd();
}

FString Observe_TrimQuotes_UnquotedBoundary()
{
	FString s = "Plain";
	bool bQuotesRemoved = true;
	FString Result = s.TrimQuotes(bQuotesRemoved);
	return bQuotesRemoved ? "failed" : Result;
}
