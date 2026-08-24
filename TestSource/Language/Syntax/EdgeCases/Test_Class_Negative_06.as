// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: invalid member type.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 6 AssertFailsToCompile.
// sha256=25ca624ace26c8855a4e78af461170e796237e6797e14a4bbf3fe5a6408c2a25; lines 164-169.
// Expected diagnostic: NonExistentType is not a known type for member X.
// DiagnosticOnly. Do not replace the member type with int.

class AClassBadMemberActor : AActor
{
	NonExistentType X;
}
