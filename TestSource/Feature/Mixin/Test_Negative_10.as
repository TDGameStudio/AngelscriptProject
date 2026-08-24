// Theme: Feature.Mixin. NegativeDiagnostic: mixin keyword typo `mixn`.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 10 AssertFailsToCompile.
// Expected diagnostic: "Mixin keyword typo should fail".
// Isolate this failing program. DiagnosticOnly.

mixn class UBadMixin
{
	int X = 0;
}
