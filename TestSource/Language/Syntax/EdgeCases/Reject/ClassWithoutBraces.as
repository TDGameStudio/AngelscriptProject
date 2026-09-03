/**
 * A class declaration with no body is rejected. This file is the illegal program
 * itself; do not add the omitted braces, since the missing body is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassWithoutBraces
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassWithoutBraces
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a class declaration terminated before its body
 * @Return does not compile; diagnostic "class body / opening brace missing"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=b3d9e012602005602c05682b07f2ffef16fbf5dfec080cac19e6186f955d83a2; lines 140-142.
 * @Provenance Expected diagnostic: class body / opening brace missing after AClassNoBraceActor.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class AClassNoBraceActor : AActor
