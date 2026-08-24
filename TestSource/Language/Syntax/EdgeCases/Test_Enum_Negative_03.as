// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: non-integer enumerator.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 3 AssertFailsToCompile.
// sha256=f434fc5c56008c6419b3ae28e0474851c4876463a21c593ab15b7c2ff6741ec7; lines 392-394.
// Expected diagnostic: enumerator Value1 cannot be initialized from "hello".
// DiagnosticOnly. Do not replace the string with an integer.

enum EEnumBadVal
{
	Value1 = "hello"
}
