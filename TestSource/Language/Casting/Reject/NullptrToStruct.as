/**
 * Assigning nullptr to a struct is rejected: structs are value types and have
 * no null state. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrToStruct
 * @Harness CompileReject
 * @Tag Language.Casting.NullptrToStruct
 * @Kind CompileReject
 * @Covers Casting.Nullptr
 * @Inputs FVector V = nullptr
 * @Return does not compile; diagnostic "nullptr assigned to struct should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

/** */
void Test()
{
	FVector V = nullptr;
}
