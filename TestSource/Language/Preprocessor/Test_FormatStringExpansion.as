// Theme: Language.Preprocessor. Positive f-string expansion to concatenation.
// C++: AngelscriptPreprocessorLiteralTests.cpp::FormatStringExpansion
// sha256=d247231a2bc9f60846905f1483acc0caf4207b286290c48264fcb62390cf62ae; lines 395-404.
// Oracle: Entry() == BuildGreeting("World").Len() == 12 ("Hello World!").
// Extra: empty Name yields "Hello !" length 8. DefaultSafe.

FString BuildGreeting(FString Name)
{
	return f"Hello {Name}!";
}

int Entry()
{
	return BuildGreeting("World").Len();
}

bool Observe_Entry_Nominal()
{
	return Entry() == 12 && BuildGreeting("World") == "Hello World!";
}

bool Observe_BuildGreeting_EmptyDefault()
{
	return BuildGreeting("").Len() == 8 && BuildGreeting("") == "Hello !";
}

bool Observe_BuildGreeting_CopyIndependence()
{
	FString First = BuildGreeting("World");
	FString Second = First;
	First = BuildGreeting("Other");
	return Second == "Hello World!" && First == "Hello Other!" && Entry() == 12;
}
