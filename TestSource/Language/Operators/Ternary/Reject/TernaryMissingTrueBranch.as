/**
 * A ternary with no true branch is rejected: both branches are required. This
 * file is the illegal program itself; do not insert a true-branch expression,
 * since the missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryMissingTrueBranch
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryMissingTrueBranch
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs true ? : 0 with nothing between ? and :
 * @Return does not compile; diagnostic "ternary without true branch"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_NoTrue; lines 615-617;
 * @Provenance sha256=1101146b037362d36e678fea9ddc885f3021eaed1a1ed20996e3997877d0dfca.
 * @Provenance Expected diagnostic: ternary without true branch.
 * @Provenance Do not insert a true-branch expression that would make this compile. DiagnosticOnly.
 */

void Test()
{
	int X = true ? : 0;
}
