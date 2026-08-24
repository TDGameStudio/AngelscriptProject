// Theme: Language.Preprocessor. Isolated C++ descriptor failure; the script text itself is valid.
// C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddSourceRejectsInvalidVirtualPathDescriptor
// sha256=e2d74870cc365e51c9da322bea84692cbc90391356ae8ea2f52d83e605d40abe; lines 118-123.
// Expected diagnostic: "Invalid Angelscript source descriptor" before source text is compiled.
// CSV DiagnosticOnly is the AddSource API, not an AngelScript syntax error. Entry() == 13 if compiled.
// Extra: repeat stays 13.

int Entry()
{
	return 13;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 13;
}

bool Observe_Entry_RepeatBoundary()
{
	return Entry() == 13 && Entry() == 13;
}
