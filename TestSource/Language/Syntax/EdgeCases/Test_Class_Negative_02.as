// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: class without braces.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 2 AssertFailsToCompile.
// sha256=b3d9e012602005602c05682b07f2ffef16fbf5dfec080cac19e6186f955d83a2; lines 140-142.
// Expected diagnostic: class body / opening brace missing after AClassNoBraceActor.
// DiagnosticOnly. Do not add the omitted braces.

class AClassNoBraceActor : AActor
