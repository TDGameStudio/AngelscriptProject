/**
 * Using a Cast result as an rvalue with no binding is rejected: the call has
 * nothing to receive the converted handle. This file is the illegal program
 * itself. The legal nullptr-null case, where the result is bound to a local
 * and observed, lives separately in ../Function/CastNullptrIsNull.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrAsRvalue
 * @Harness CompileReject
 * @Tag Language.Casting.CastNullptrAsRvalue
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<APawn>(nullptr) as a bare expression statement
 * @Return does not compile; diagnostic "Cast on nullptr should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast on nullptr should fail".
 */

/** */
void Test()
{
	auto X = Cast<APawn>(nullptr);
}
