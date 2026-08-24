// Theme: Feature.Delegates. Isolated compile-fail: delegate without a type name.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_NoName
// sha256=0a31bb2702d11d39cd78acbf98a71a2b0d35af5ea2361e66d5edeb8873a8129c; lines 159-161.
// Expected diagnostic: "Delegate without name should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

delegate void ();
