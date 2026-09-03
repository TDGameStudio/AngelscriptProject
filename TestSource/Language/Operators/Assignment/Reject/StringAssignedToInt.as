/**
 * Assigning a string to an int variable is rejected: there is no implicit
 * conversion from text to a number. This file is the illegal program itself;
 * do not parse the string, since the type mismatch is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.StringAssignedToInt
 * @Harness CompileReject
 * @Tag Language.Operators.StringAssignedToInt
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs Declare int X = 0, then assign X = "hello"
 * @Return does not compile; diagnostic "String assigned to int"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=7daf23899fba46c66b91f4b1456804a63bdf1a09b812dadf14b19ffba41174a2; lines 504-506.
 * @Provenance Expected compile failure: "String assigned to int".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = 0;
	X = "hello";
}
