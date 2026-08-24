// Theme: Language.Preprocessor. Isolated compile-fail: import missing terminating ';'.
// C++: AngelscriptPreprocessorImportTests.cpp::MissingSemicolonReportsSyntax block 2
// sha256=81311b0280effe7c666e85a13f3a9ec3e81139c0aaff58e971050082ba39280c; lines 195-201.
// Expected diagnostic: "Import statement is missing terminating ';'." at row 1 (count 1).
// DiagnosticOnly. Do not add the semicolon or extra declarations that would compile this away.

import Tests.Preprocessor.MissingSemicolon.Shared
int UseShared()
{
	return SharedValue();
}
