/**
 * Assigning to a const is rejected: a const binding cannot be written through.
 * This file is the illegal program itself; do not drop the const, since the
 * immutability is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentToConst
 * @Harness CompileReject
 * @Tag Language.Operators.AssignmentToConst
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs Declare const int X = 5, then assign X = 10
 * @Return does not compile; diagnostic "Assignment to const"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=fdde368f9f57bed4005598462fa968c50df816cb872c477b7fe720efbbf9854e; lines 490-492.
 * @Provenance Expected compile failure: "Assignment to const".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	const int X = 5;
	X = 10;
}
