// Theme: Language.Literals.FString. NegativeDiagnostic: FText string-literal default args.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::UnsupportedFunctionSignatureBoundaries
// sha256 from TS-LANG-0148; lines 709-719.
// Expected compile failure: Default argument value "DefaultText" has type const FString.
// Isolate the failing program. DiagnosticOnly.

FString TextDefaultLiteral(FText text = "DefaultText")
{
	return text.ToString();
}

FString TextDefaultLiteralImplicit()
{
	return TextDefaultLiteral();
}
