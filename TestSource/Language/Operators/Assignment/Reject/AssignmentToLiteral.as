/**
 * Assigning to a literal is rejected: a literal is not a variable and has no
 * storage to write into. This file is the illegal program itself; do not turn
 * the literal into a variable, since the literal target is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentToLiteral
 * @Harness CompileReject
 * @Tag Language.Operators.AssignmentToLiteral
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs 5 = 10
 * @Return does not compile; diagnostic "Assignment to literal"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=284c0492775dd042de82674d7f8cea2cbe22e9f329987501770f7405ab7d231a; lines 497-499.
 * @Provenance Expected compile failure: "Assignment to literal".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	5 = 10;
}
