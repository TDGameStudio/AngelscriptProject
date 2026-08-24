// Theme: Feature.Delegates. Isolated compile-fail: nested delegate inside a class.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_NestedDelegate
// sha256=10666051980d07217f461a6ba53be2fd53ebf97faacd7f315ebe163db720f923; lines 235-240.
// Expected diagnostic: "Nested delegate inside class should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

class ADelNestedActor : AActor
{
	delegate void FOnActionNested();
}
