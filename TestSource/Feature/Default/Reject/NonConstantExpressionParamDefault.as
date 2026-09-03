/**
 * A non-constant expression as a parameter default is rejected. Defaults must
 * be compile-time constants, not GlobalVal + 1. This file is the illegal
 * program itself; do not replace the expression with a literal.
 *
 * @Theme Feature.Default
 * @Subject Default.NonConstantExpressionParamDefault
 * @Harness CompileReject
 * @Tag Feature.Default.NonConstantExpressionParamDefault
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs void Foo(int X = GlobalVal + 1) with GlobalVal = 5
 * @Return does not compile; diagnostic "Non-constant expression as default should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: non-constant expression as a parameter default.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_ParamExprDefault. Expected diagnostic: "Non-constant expression as default should fail".
 * @Provenance DiagnosticOnly. Do not replace GlobalVal + 1 with a literal.
 */

int GlobalVal = 5;

/**
 * Illegal signature: the default is a non-constant expression.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X defaulting to GlobalVal + 1
 * @Return does not compile
 * @Param X an int whose default is not a constant
 */
void Foo(int X = GlobalVal + 1)
{
}
