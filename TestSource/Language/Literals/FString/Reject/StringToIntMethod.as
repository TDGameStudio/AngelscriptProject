/**
 * FString.ToInt is not exposed by this fork, so calling it is rejected. This
 * file is the illegal program itself; do not substitute a conversion helper,
 * since the missing method is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringToIntMethod
 * @Harness CompileReject
 * @Tag Language.Literals.StringToIntMethod
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs Value.ToInt() where Value is an FString
 * @Return does not compile; diagnostic "no matching method 'ToInt'"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 2
 */

int TryStringToIntMethod()
{
	FString Value = "42";
	return Value.ToInt();
}
