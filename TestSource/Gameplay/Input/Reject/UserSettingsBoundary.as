/**
 * Isolated compile-fail: user settings and mappable profiles stay boundaries. C++
 * compiles this as the module ASCoverageInput_UserSettingsBoundary and expects
 * failure. The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Gameplay.Input
 * @Subject Input.UserSettingsBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Input.UserSettingsBoundary
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: user settings and mappable profiles stay boundaries.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
 * @Provenance Do not drop UEnhancedInputUserSettings or UPlayerMappableKeyProfile.
 */

/**
 * The isolated failing program: UEnhancedInputUserSettings and UPlayerMappableKeyProfile are not bound.
 *
 * @Kind CompileReject
 * @Covers Input.UserSettingsBoundary
 * @Inputs none
 * @Return does not compile; user settings and mappable profiles stay explicit boundaries
 */
int UserSettingsBoundary()
{
	UEnhancedInputUserSettings Settings;
	UPlayerMappableKeyProfile Profile;
	return Settings != nullptr || Profile != nullptr ? 1 : 0;
}
