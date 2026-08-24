// Theme: Feature.Delegates. Isolated compile-fail: unknown event parameter type.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_EventWithInvalidParamType
// sha256 from theme-refs TS-FEAT-0341; lines 280-282.
// Expected diagnostic: "Event with invalid parameter type should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

event void FOnChangedBadParam(NonExistentType X);
