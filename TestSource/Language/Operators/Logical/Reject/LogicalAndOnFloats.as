/**
 * Applying logical and to two floats is rejected: the operands must be boolean.
 * This file is the illegal program itself; do not convert them, since the
 * non-boolean operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalAndOnFloats
 * @Harness CompileReject
 * @Tag Language.Operators.LogicalAndOnFloats
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs 1.0f && 2.0f assigned to a bool
 * @Return does not compile; diagnostic "Logical AND on floats"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=345606aba8265f0434788a1c64dee62af4162f1fba2385e49f8e2b66c4f79437; lines 352-354.
 * @Provenance Expected compile failure: "Logical AND on floats".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	bool X = 1.0f && 2.0f;
}
