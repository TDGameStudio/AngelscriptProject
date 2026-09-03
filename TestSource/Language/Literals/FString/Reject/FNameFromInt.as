/**
 * Constructing an FName from an integer is rejected: a name is built from text
 * or taken from an existing name, not from a number. This file is the illegal
 * program itself; do not convert the integer to text, since the number is the
 * point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FNameFromInt
 * @Harness CompileReject
 * @Tag Language.Literals.FNameFromInt
 * @Kind CompileReject
 * @Covers Literals.FName
 * @Inputs FName(42) constructing a name from an int
 * @Return does not compile; diagnostic "no matching constructor for FName"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::FName_Mixed block 4
 */

/** */
void Test()
{
	FName N = FName(42);
}
