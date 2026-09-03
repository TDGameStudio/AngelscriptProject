/**
 * A bitwise xor on two booleans is rejected: bitwise operators apply to
 * integers only. This file is the illegal program itself; do not convert the
 * operands, since the boolean operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseXorOnBool
 * @Harness CompileReject
 * @Tag Language.Operators.BitwiseXorOnBool
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs A ^ B where both are bool, assigned to an int
 * @Return does not compile; diagnostic "Bitwise XOR on bool"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=5aae85ebeacb4c1da4700bf3c39ada5eeea1beea69f2532161efa1f16701f20e; lines 263-265.
 * @Provenance Expected compile failure: "Bitwise XOR on bool".
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: bool bitwise is allowed).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	bool A = true;
	bool B = false;
	int X = A ^ B;
}
