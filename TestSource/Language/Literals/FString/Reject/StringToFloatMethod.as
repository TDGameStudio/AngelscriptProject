/**
 * FString.ToFloat is not exposed by this fork, so calling it is rejected. This
 * file is the illegal program itself; do not substitute a conversion helper,
 * since the missing method is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringToFloatMethod
 * @Harness CompileReject
 * @Tag Language.Literals.StringToFloatMethod
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs Value.ToFloat() where Value is an FString
 * @Return does not compile; diagnostic "no matching method 'ToFloat'"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 3
 */

/** */
float TryStringToFloatMethod()
{
	FString Value = "3.14";
	return Value.ToFloat();
}
