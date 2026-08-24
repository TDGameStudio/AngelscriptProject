// Theme: Feature.Mixin. NegativeDiagnostic: mixin class without a U prefix.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 1 AssertFailsToCompile.
// Expected diagnostic: "Mixin without U prefix should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class HealthMixin
{
	int Health = 100;
}
