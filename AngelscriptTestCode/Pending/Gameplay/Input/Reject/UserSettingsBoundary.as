/**
 * @version v1
 * @summary Isolated compile-fail: user settings and mappable profiles stay boundaries. C++ compiles this as the module ASCoverageInput_UserSettingsBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: user settings and mappable profiles stay boundaries. C++ compiles this as the module ASCoverageInput_UserSettingsBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Negative
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
/** @end */
