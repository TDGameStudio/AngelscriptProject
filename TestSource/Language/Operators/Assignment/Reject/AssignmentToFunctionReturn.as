/**
 * Assigning to a function call is rejected: the call is not an lvalue and has
 * no storage to write into. This file is the illegal program itself; do not
 * bind the result to a variable, since the call target is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentToFunctionReturn
 * @Harness CompileReject
 * @Tag Language.Operators.AssignmentToFunctionReturn
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs Foo() = 5 where Foo returns an int
 * @Return does not compile; diagnostic "Assign to function return"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=37fb3bb1f74ff72e5ae82993351cc06f74ec1630886346dd63b9b0ff9bc92eac; lines 518-521.
 * @Provenance Expected compile failure: "Assign to function return".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
int Foo()
{
	return 1;
}

/** */
void Test()
{
	Foo() = 5;
}
