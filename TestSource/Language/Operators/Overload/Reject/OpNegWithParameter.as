/**
 * opNeg is unary, so declaring it with a parameter is rejected. This file is
 * the illegal program itself; do not drop the parameter, since the extra one is
 * the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpNegWithParameter
 * @Harness CompileReject
 * @Tag Language.Operators.OpNegWithParameter
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opNeg taking an int parameter
 * @Return does not compile; diagnostic "opNeg with parameter should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOONegWithParam; lines 350-357;
 * @Provenance sha256=39e871dfeb3d8e8c8fc49788cca968008d657a2c2f36b8707c12710e4f3fe191.
 * @Provenance Expected diagnostic: opNeg with parameter should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FVecNegParam
{
	int X = 0;

	/**
	 * Takes a parameter where a unary operator owes none.
	 */
	FVecNegParam opNeg(int Dummy) const
	{
		return FVecNegParam();
	}
}
