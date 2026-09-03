/**
 * A name literal with nothing between the quotes is rejected: the literal must
 * carry a name. This file is the illegal program itself; do not supply a name
 * or use NAME_None, since the empty literal is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.EmptyNameLiteral
 * @Harness CompileReject
 * @Tag Language.Literals.EmptyNameLiteral
 * @Kind CompileReject
 * @Covers Literals.FName
 * @Inputs FName N = n; with no quoted name
 * @Return does not compile; diagnostic "empty name literal"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::FName_Mixed block 3
 */

void Test()
{
	FName N = n;
}
