// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: struct inheritance.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 5 AssertFailsToCompile.
// sha256=4f7210fd6b073ca047393be072d7e63f95b16dcc7c1c53d8eb7204d0d61871f9; lines 314-317.
// Expected diagnostic: Error parsing script struct FChild. Structs may not inherit from anything.
// DiagnosticOnly. Do not flatten FChild into FBase.

struct FBase
{
	int X;
}

struct FChild : FBase
{
	int Y;
}
