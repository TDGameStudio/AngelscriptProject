// Theme: Feature.Delegates. Isolated compile-fail: event with a non-void return.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_VoidDelegateWithReturn
// sha256 from theme-refs TS-FEAT-0340; lines 268-270.
// Expected diagnostic: "Event (multicast) with non-void return should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

event int FOnChangedReturn();
