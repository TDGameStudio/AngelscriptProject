// Theme: Language.Preprocessor. Isolated compile-fail: #include is unsupported.
// C++: AngelscriptCoveragePreprocessorTests.cpp::IncludeDirectiveReportsUnsupportedDiagnostic
// AssertPreprocessFailed; lines 309-315;
// sha256=cd2dd8df920476323ae38c27b1300aa96be41a9f59ae502ed630333525fda28d.
// Expected diagnostic: "Unsupported preprocessor directive '#include'. Use import or automatic imports instead."
// Do not replace #include with import.
// DiagnosticOnly.

#include "Shared.as"
int Entry()
{
	return 1;
}
