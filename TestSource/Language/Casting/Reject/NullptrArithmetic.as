/**
 * Using nullptr in arithmetic is rejected: it is a handle literal and takes
 * no part in numeric expressions. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrArithmetic
 * @Harness CompileReject
 * @Tag Language.Casting.NullptrArithmetic
 * @Kind CompileReject
 * @Covers Casting.Nullptr
 * @Inputs int X = nullptr + 1
 * @Return does not compile; diagnostic "nullptr in arithmetic should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

void Test()
{
	int X = nullptr + 1;
}
