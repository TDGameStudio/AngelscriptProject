// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unknown super type.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 4 AssertFailsToCompile.
// sha256=5d3c4b5d9b4ec87c91c45c1e703179cd749dd5add1b163cbd2e2366725586b33; lines 152-154.
// Expected diagnostic: has an unknown super type ANonExistentActor.
// DiagnosticOnly. Do not replace the parent with AActor.

class AClassBadParentActor : ANonExistentActor
{
}
