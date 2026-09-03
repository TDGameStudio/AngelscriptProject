/**
 * A ternary whose two branches have different types is rejected: both branches
 * must produce the same type. This file is the illegal program itself; do not
 * cast or drop either branch, since the mismatch is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryBranchTypeMismatch
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryBranchTypeMismatch
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs true ? 1 : "hello" mixing an int and a string
 * @Return does not compile; diagnostic "ternary branch type mismatch (int vs string)"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_TypeMismatch; lines 601-603;
 * @Provenance sha256=213c16aa99ff857e8a9133ffc09fdebbf075d8638bb1669f208b6d1518d08138.
 * @Provenance Expected diagnostic: ternary branch type mismatch (int vs string).
 * @Provenance Do not cast or drop either branch to make this compile. DiagnosticOnly.
 */

/** */
void Test()
{
	auto X = true ? 1 : "hello";
}
