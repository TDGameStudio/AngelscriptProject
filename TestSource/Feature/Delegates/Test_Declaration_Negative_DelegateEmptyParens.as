// Theme: Feature.Delegates. Isolated compile-fail: delegate without parentheses.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateEmptyParens
// sha256 from theme-refs TS-FEAT-0342; lines 292-294.
// Expected diagnostic: "Delegate without parentheses should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

delegate void FOnActionNoParens;
