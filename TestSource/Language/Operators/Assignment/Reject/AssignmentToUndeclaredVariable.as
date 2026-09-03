/**
 * Assigning to a variable that was never declared is rejected: a name must be
 * declared before it can be written. This file is the illegal program itself;
 * do not declare the variable, since the undeclared name is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentToUndeclaredVariable
 * @Harness CompileReject
 * @Tag Language.Operators.AssignmentToUndeclaredVariable
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs UndeclaredVar = 5 with no declaration in scope
 * @Return does not compile; diagnostic "Assign to undeclared variable"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=bd1ea25508b13031efc6cf5d33b3dbe394d9a49197fd89498bd3b01662202049; lines 526-528.
 * @Provenance Expected compile failure: "Assign to undeclared variable".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	UndeclaredVar = 5;
}
