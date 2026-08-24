// Theme: Feature.Mixin. NegativeDiagnostic: mixin applied to a struct.
// C++: AngelscriptSyntaxMixinTests.cpp::Negative block 3 AssertFailsToCompile.
// Expected diagnostic: "Mixin on struct should fail".
// Isolate this failing program. DiagnosticOnly.

mixin class UHealthMixinOnStruct
{
	int Health = 100;
}

struct FMixStruct
{
	mixin UHealthMixinOnStruct;
}
