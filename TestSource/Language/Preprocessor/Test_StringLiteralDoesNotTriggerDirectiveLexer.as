// Theme: Language.Preprocessor. Positive: #if inside a string is not a directive.
// C++: AngelscriptPreprocessorDirectiveTests.cpp::StringLiteralDoesNotTriggerDirectiveLexer
// Compile + ExecuteIntFunction; lines 342-351;
// sha256=ca1aaf735fd4e9d269079c4f2376776b5588f50a7b821454827b88ae71d770f1.
// Oracle: Entry() == 42; BuildMarker equals "debug #if RELEASE #else keep".
// Extra: a mismatched compare would return 0; two BuildMarker calls match.
// DefaultSafe. Source owns locals.

FString BuildMarker()
{
	return "debug #if RELEASE #else keep";
}

int Entry()
{
	return BuildMarker() == "debug #if RELEASE #else keep" ? 42 : 0;
}

bool Observe_Entry_StringLiteralNotDirective()
{
	return Entry() == 42;
}

bool Observe_BuildMarker_CopyIndependence()
{
	FString First = BuildMarker();
	FString Second = BuildMarker();
	return First == "debug #if RELEASE #else keep" && First == Second;
}
