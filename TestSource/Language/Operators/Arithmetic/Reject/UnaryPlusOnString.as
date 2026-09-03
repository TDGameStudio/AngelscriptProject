/**
 * A unary plus on a string is rejected: unary plus applies to numbers. This
 * file is the illegal program itself; do not drop the operator, since the
 * unsupported operand is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.UnaryPlusOnString
 * @Harness CompileReject
 * @Tag Language.Operators.UnaryPlusOnString
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs +"hello" assigned to an FString
 * @Return does not compile; diagnostic "Unary plus on string"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=4690e400b64ee47644beab64d13ca6961f9f25625eb969c75e60b8c30df8bf79; lines 168-170.
 * @Provenance Expected compile failure: "Unary plus on string".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	FString S = +"hello";
}
