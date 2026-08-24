// Theme: Feature.Mixin. NegativeDiagnostic: mixin of a type that does not exist.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 2 AssertFailsToCompile.
// Expected diagnostic: "Using non-existent mixin should fail".
// Isolate this failing program. DiagnosticOnly.

class AMixNonExistActor : AActor
{
	mixin UNonExistentMixin;
}
