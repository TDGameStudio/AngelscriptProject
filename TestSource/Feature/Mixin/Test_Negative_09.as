// Theme: Feature.Mixin. NegativeDiagnostic: circular mixin references.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 9 AssertFailsToCompile.
// Expected diagnostic: "Circular mixin reference should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UMixinA
{
	mixin UMixinB;
}

mixin class UMixinB
{
	mixin UMixinA;
}
