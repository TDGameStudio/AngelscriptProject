/**
 * FCString::Atof is not exposed by this fork, so calling it is rejected. This
 * file is the illegal program itself; do not substitute a conversion helper,
 * since the missing function is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FCStringAtof
 * @Harness CompileReject
 * @Tag Language.Literals.FCStringAtof
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FCString::Atof(Value) where Value is an FString
 * @Return does not compile; diagnostic "no matching function 'Atof'"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 5
 */

/** */
float TryFCStringAtof()
{
	FString Value = "3.14";
	return FCString::Atof(Value);
}
