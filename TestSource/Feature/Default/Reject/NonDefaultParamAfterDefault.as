/**
 * A required parameter after a defaulted parameter is rejected. Once a
 * parameter has a default, every parameter after it must also have one.
 * This file is the illegal program itself; do not add a default for Y.
 *
 * @Theme Feature.Default
 * @Subject Default.NonDefaultParamAfterDefault
 * @Harness CompileReject
 * @Tag Feature.Default.NonDefaultParamAfterDefault
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs void Foo(int X = 5, int Y)
 * @Return does not compile; diagnostic "Non-default param after default should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: non-default parameter after a default.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_ParamOrder. Expected diagnostic: "Non-default param after default should fail".
 * @Provenance DiagnosticOnly. Do not add a default for Y.
 */

/**
 * Illegal signature: a required int follows a defaulted int.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X = 5 followed by required int Y
 * @Return does not compile
 * @Param X a defaulted int
 * @Param Y a required int after a default
 */
void Foo(int X = 5, int Y)
{
}
