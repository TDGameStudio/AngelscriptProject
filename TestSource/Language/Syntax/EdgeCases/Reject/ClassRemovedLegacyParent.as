/**
 * Deriving from the removed UAngelscriptComponent is rejected. This file is the
 * illegal program itself; do not retarget the parent to UActorComponent, since the
 * legacy parent is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassRemovedLegacyParent
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassRemovedLegacyParent
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a class deriving from the removed UAngelscriptComponent
 * @Return does not compile; diagnostic "UAngelscriptComponent is not a valid parent"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=995e469595bd058e1e216d6b222a354767e0fea4ba617e15265cc956924f602e; lines 158-160.
 * @Provenance Expected diagnostic: UAngelscriptComponent is not a valid parent.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class ULegacyAngelscriptComponent : UAngelscriptComponent
{
}
