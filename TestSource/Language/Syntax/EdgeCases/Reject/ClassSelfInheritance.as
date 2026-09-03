/**
 * A class deriving from itself is rejected. This file is the illegal program
 * itself; do not retarget the parent to AActor, since the self reference is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassSelfInheritance
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassSelfInheritance
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a class naming itself as its own parent
 * @Return does not compile; diagnostic "ASelfActor inherits from itself"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 10 AssertFailsToCompile.
 * @Provenance sha256=9e0f5691dbe1c49bccf523f027d58d2eba25489439a908dede478dcdcdda9296; lines 201-203.
 * @Provenance Expected diagnostic: ASelfActor inherits from itself / unknown super type.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class ASelfActor : ASelfActor
{
}
