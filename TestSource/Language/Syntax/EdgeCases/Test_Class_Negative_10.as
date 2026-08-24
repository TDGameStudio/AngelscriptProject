// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: self-inheritance.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 10 AssertFailsToCompile.
// sha256=9e0f5691dbe1c49bccf523f027d58d2eba25489439a908dede478dcdcdda9296; lines 201-203.
// Expected diagnostic: ASelfActor inherits from itself / unknown super type.
// DiagnosticOnly. Do not retarget the parent to AActor.

class ASelfActor : ASelfActor
{
}
