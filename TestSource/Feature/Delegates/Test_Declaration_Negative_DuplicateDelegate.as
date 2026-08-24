// Theme: Feature.Delegates. Isolated compile-fail: duplicate delegate type name.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DuplicateDelegate
// sha256=b3cce4f2b3415ab9aece4f5d530e017766f598ecd792d1e6b6d0d8637e984207; lines 198-201.
// Expected diagnostic: "Duplicate delegate name should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

delegate void FOnActionDup();
delegate void FOnActionDup(int X);
