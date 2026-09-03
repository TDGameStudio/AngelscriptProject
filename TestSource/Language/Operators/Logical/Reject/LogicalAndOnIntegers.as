/**
 * Applying logical and to two integers is rejected: the operands must be
 * boolean. This file is the illegal program itself; do not convert them, since
 * the non-boolean operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalAndOnIntegers
 * @Harness CompileReject
 * @Tag Language.Operators.LogicalAndOnIntegers
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs 1 && 2 assigned to an int
 * @Return does not compile; diagnostic "Logical AND on integers"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=5b1733630273ecc361725d863283d485013d8b06f8e21e4d762432ff21653f6c; lines 317-319.
 * @Provenance Expected compile failure: "Logical AND on integers".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = 1 && 2;
}
