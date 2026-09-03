/**
 * Add-assigning a string to an int variable is rejected: the compound
 * assignment has no meaning across those types. This file is the illegal
 * program itself; do not parse the string, since the type mismatch is the
 * point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AddAssignStringToInt
 * @Harness CompileReject
 * @Tag Language.Operators.AddAssignStringToInt
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs Declare int X = 0, then X += "hello"
 * @Return does not compile; diagnostic "Add-assign string to int"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=396d900cae29aecba4a637d3db4b1bd4a8331dde103f4368f3e856b24798eadd; lines 511-513.
 * @Provenance Expected compile failure: "Add-assign string to int".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int X = 0;
	X += "hello";
}
