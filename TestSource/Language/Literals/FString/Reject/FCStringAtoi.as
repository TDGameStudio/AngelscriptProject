/**
 * FCString::Atoi is not exposed by this fork, so calling it is rejected. This
 * file is the illegal program itself; do not substitute a conversion helper,
 * since the missing function is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FCStringAtoi
 * @Harness CompileReject
 * @Tag Language.Literals.FCStringAtoi
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FCString::Atoi(Value) where Value is an FString
 * @Return does not compile; diagnostic "no matching function 'Atoi'"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 4
 */

int TryFCStringAtoi()
{
	FString Value = "42";
	return FCString::Atoi(Value);
}
