/**
 * Assigning nullptr to a bool is rejected: nullptr is a handle literal, not a
 * truth value. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrToBool
 * @Harness CompileReject
 * @Tag Language.Casting.NullptrToBool
 * @Kind CompileReject
 * @Covers Casting.Nullptr
 * @Inputs bool B = nullptr
 * @Return does not compile; diagnostic "nullptr assigned to bool should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

/** */
void Test()
{
	bool B = nullptr;
}
