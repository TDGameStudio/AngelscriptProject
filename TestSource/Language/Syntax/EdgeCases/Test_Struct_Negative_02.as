// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: duplicate struct name.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 2 AssertFailsToCompile.
// sha256=37176c66bcfe4b62f9a287735b1ebea0c4984748fb1770322c124307da041644; lines 284-287.
// Expected diagnostic: FDup is declared twice.
// DiagnosticOnly. Do not rename the second struct.

struct FDup
{
	int X;
}

struct FDup
{
	int Y;
}
