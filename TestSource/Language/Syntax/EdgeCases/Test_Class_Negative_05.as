// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: removed legacy parent.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 5 AssertFailsToCompile.
// sha256=995e469595bd058e1e216d6b222a354767e0fea4ba617e15265cc956924f602e; lines 158-160.
// Expected diagnostic: UAngelscriptComponent is not a valid parent.
// DiagnosticOnly. Do not retarget to UActorComponent.

class ULegacyAngelscriptComponent : UAngelscriptComponent
{
}
