/**
 * Assigning nullptr to an int is rejected: nullptr is a handle literal, not a
 * numeric zero. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrToInt
 * @Harness CompileReject
 * @Tag Language.Casting.NullptrToInt
 * @Kind CompileReject
 * @Covers Casting.Nullptr
 * @Inputs int X = nullptr
 * @Return does not compile; diagnostic "nullptr assigned to int should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

void Test()
{
	int X = nullptr;
}
