// Theme: Feature.Delegates. Isolated compile-fail: missing semicolon after delegate.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_MissingSemicolon
// sha256=b6d3fc273f90b27703cb045cb238805a6e3fd454623fd21f69a56a8184b86073; lines 211-213.
// Expected diagnostic: "Missing semicolon after delegate should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

delegate void FOnActionNoSemi()
