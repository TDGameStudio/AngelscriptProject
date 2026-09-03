/**
 * Two adjacent plus operators are rejected: the parser cannot separate an
 * addition from an increment here. This file is the illegal program itself; do
 * not insert a separator, since the doubled operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.DoubleOperatorInExpression
 * @Harness CompileReject
 * @Tag Language.Operators.DoubleOperatorInExpression
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs 1 ++ 2 assigned to an int
 * @Return does not compile; diagnostic "Double operator in expression"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=3db5b63caf0e99c536af231745c9cf1921aa6cb54a840541a275c5240ce42860; lines 152-154.
 * @Provenance Expected compile failure: "Double operator in expression".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int X = 1 ++ 2;
}
