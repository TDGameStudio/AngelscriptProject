// Theme: Feature.Mixin. NegativeDiagnostic: mixin inheriting another mixin.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 7 AssertFailsToCompile.
// Expected diagnostic: "Mixin inheriting mixin should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UBaseMixin
{
	int X = 0;
}

mixin class UChildMixin : UBaseMixin
{
	int Y = 0;
}
