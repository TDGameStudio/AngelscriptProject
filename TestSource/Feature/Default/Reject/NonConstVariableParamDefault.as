/**
 * A non-const variable as a parameter default is rejected. Defaults must be
 * compile-time constants, not a mutable global. This file is the illegal
 * program itself; do not replace GlobalVal with a literal.
 *
 * @Theme Feature.Default
 * @Subject Default.NonConstVariableParamDefault
 * @Harness CompileReject
 * @Tag Feature.Default.NonConstVariableParamDefault
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs void Foo(int X = GlobalVal) with GlobalVal = 5
 * @Return does not compile; diagnostic "Non-const variable as default should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: non-const variable as a parameter default.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_ParamNonConst. Expected diagnostic: "Non-const variable as default should fail".
 * @Provenance DiagnosticOnly. Do not replace GlobalVal with a literal.
 */

int GlobalVal = 5;

/**
 * Illegal signature: the default names a non-const variable.
 *
 * @Kind CompileReject
 * @Covers Default.Param
 * @Inputs int X defaulting to GlobalVal
 * @Return does not compile
 * @Param X an int whose default is a mutable global
 */
void Foo(int X = GlobalVal)
{
}
