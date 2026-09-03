/**
 * Assigning nullptr to a float is rejected: nullptr is a handle literal, not a
 * numeric zero. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrToFloat
 * @Harness CompileReject
 * @Tag Language.Casting.NullptrToFloat
 * @Kind CompileReject
 * @Covers Casting.Nullptr
 * @Inputs float X = nullptr
 * @Return does not compile; diagnostic "nullptr assigned to float should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

/** */
void Test()
{
	float X = nullptr;
}
