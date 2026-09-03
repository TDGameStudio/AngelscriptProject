/**
 * Adding two booleans is rejected: booleans have no arithmetic. This file is
 * the illegal program itself; do not declare anything that would compile it
 * away, since the type mismatch is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BoolAddition
 * @Harness CompileReject
 * @Tag Language.Operators.BoolAddition
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs A + B where both are bool, assigned to an int
 * @Return does not compile; diagnostic "bool addition"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative block 2 AssertFailsToCompile
 * @Provenance (currently #if 0, implicit-conversion-permissive).
 * @Provenance sha256=eeb7095010fc58c679289aa5481f18d0887382a88bb38e92bc8873f652e499f4; lines 108-110.
 * @Provenance Expected diagnostic: bool addition.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

void Test()
{
	bool A = true;
	bool B = false;
	int X = A + B;
}
