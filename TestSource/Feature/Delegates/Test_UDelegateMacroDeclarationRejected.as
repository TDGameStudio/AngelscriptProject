// Theme: Feature.Delegates. Isolated compile-fail: UDELEGATE() macro spelling is rejected.
// C++: AngelscriptCoverageMacrosTests.cpp::UDelegateMacroDeclarationRejected
// CompileAndExpectFailure: "Expected identifier" and "Instead found '('.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

UDELEGATE()
delegate void FCoverageUnsupportedUDelegate(int Value);
