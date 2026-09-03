/**
 * Adding an int to a string is rejected: the two operands have no common
 * arithmetic. This file is the illegal program itself; do not declare
 * anything that would compile it away, since the type mismatch is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.StringPlusInt
 * @Harness CompileReject
 * @Tag Language.Operators.StringPlusInt
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs "hello" + 1 assigned to an int
 * @Return does not compile; diagnostic "string + int type mismatch"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=3ae1c001f1510d0abae01b46a63cf59f59361de905988ab058779f0fda7bab5e; lines 98-100.
 * @Provenance Expected diagnostic: string + int type mismatch.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

void Test()
{
	int X = "hello" + 1;
}
