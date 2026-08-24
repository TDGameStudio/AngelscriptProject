// Theme: Feature.Delegates. Isolated compile-fail: delegate declaration with a body.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateWithBody
// sha256=cabd5f68dc793436e71556d01ae0f5f174d7c84877321f9294f04386bb89a4de; lines 223-225.
// Expected diagnostic: "Delegate with body should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

delegate void FOnActionBody()
{
}
