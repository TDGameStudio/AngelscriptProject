// Theme: Language.Literals.FString. Positive Replace/ReplaceInline/escape helpers.
// C++: AngelscriptCoverageFStringMethodTests.cpp::ReplaceMethods
// sha256 from TS-LANG-0154; lines 474-517.
// Oracle: Hello Universe; orange x3; Hello World; 2:green green blue; Hello World; escaped/unescaped.
// Extra: replace missing needle is identity; empty replace with empty is identity.
// DefaultSafe. Source owns locals.

FString TestReplace()
{
	FString s = "Hello World";
	return s.Replace("World", "Universe");
}

FString TestReplaceMultiple()
{
	FString s = "apple apple apple";
	return s.Replace("apple", "orange");
}

FString TestReplaceNotFound()
{
	FString s = "Hello World";
	return s.Replace("Test", "New");
}

FString TestReplaceInline()
{
	FString s = "red red blue";
	int Count = s.ReplaceInline("red", "green");
	return FString::Format("{0}:{1}", Count, s);
}

FString TestReplaceCaseSensitiveMiss()
{
	FString s = "Hello hello";
	return s.Replace("hello", "World", ESearchCase::CaseSensitive);
}

FString TestEscapedCharacters()
{
	FString s = "Line\nTab\t";
	return s.ReplaceCharWithEscapedChar();
}

FString TestUnescapedCharacters()
{
	FString s = "Line\\nTab\\t";
	return s.ReplaceEscapedCharWithChar();
}

bool Observe_ReplaceMethods_Nominal()
{
	return TestReplace() == "Hello Universe"
		&& TestReplaceMultiple() == "orange orange orange"
		&& TestReplaceNotFound() == "Hello World"
		&& TestReplaceInline() == "2:green green blue"
		&& TestReplaceCaseSensitiveMiss() == "Hello World"
		&& TestEscapedCharacters() == "Line\\nTab\\t"
		&& TestUnescapedCharacters() == "Line\nTab\t";
}

FString Observe_Replace_EmptyHaystack()
{
	FString Empty;
	return Empty.Replace("Test", "New");
}

FString Observe_Replace_NotFoundIdentity()
{
	FString s = "Hello World";
	FString Copy = s;
	return s.Replace("Test", "New") == Copy ? Copy : "failed";
}
