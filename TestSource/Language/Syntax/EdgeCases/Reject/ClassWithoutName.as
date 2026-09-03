/**
 * A class declaration with no name is rejected. C++ currently wraps this
 * AssertFailsToCompile in #if 0 because an anonymous class trips a
 * preprocessor ensure crash, but the case remains a reject by intent. This file
 * is the illegal program itself; do not invent a class name, since the missing
 * name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassWithoutName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassWithoutName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a class declaration with no identifier
 * @Return does not compile; a successful compile counts as failure
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 1 is #if 0
 * @Provenance AssertFailsToCompile (preprocessor-ensure-crash on anonymous class).
 * @Provenance sha256=587cd2a88497e058d85c07de93ef8d8bcb4d3cf694e03bf9645cb68f59632d47; lines 133-135.
 * @Provenance Expected diagnostic: unnamed class / DetectClasses ensure.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class : AActor
{
}
