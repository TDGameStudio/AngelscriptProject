// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: invalid struct member type.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 3 AssertFailsToCompile.
// sha256=7a8046467be3c260491d762706625b46d3430becce88e913c9b718f60fb4c1ff; lines 291-293.
// Expected diagnostic: NonExistentType is not a known type for member X.
// DiagnosticOnly. Do not replace the member type with int.

struct FStructBadMember
{
	NonExistentType X;
}
