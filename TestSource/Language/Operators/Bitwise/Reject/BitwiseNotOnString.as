/**
 * A bitwise not on a string is rejected: bitwise operators apply to integers
 * only. This file is the illegal program itself; do not substitute a different
 * operand, since the string is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseNotOnString
 * @Harness CompileReject
 * @Tag Language.Operators.BitwiseNotOnString
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs ~"hello"
 * @Return does not compile; diagnostic "Bitwise NOT on string"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=232ef98ec5a8af2fbfdea957ad5b239074b55813572514f907c55dd12cc9aa15; lines 247-249.
 * @Provenance Expected compile failure: "Bitwise NOT on string".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	auto S = ~"hello";
}
