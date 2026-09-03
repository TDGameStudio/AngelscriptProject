/**
 * Deriving from a type that does not exist is rejected. This file is the illegal
 * program itself; do not replace the parent with AActor, since the unknown
 * parent is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassUnknownSuperType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassUnknownSuperType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a class deriving from an undeclared parent
 * @Return does not compile; diagnostic "has an unknown super type ANonExistentActor"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=5d3c4b5d9b4ec87c91c45c1e703179cd749dd5add1b163cbd2e2366725586b33; lines 152-154.
 * @Provenance Expected diagnostic: has an unknown super type ANonExistentActor.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class AClassBadParentActor : ANonExistentActor
{
}
