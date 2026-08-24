// Theme: Gameplay.Input. Isolated compile-fail: user settings and mappable profiles stay boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop UEnhancedInputUserSettings or UPlayerMappableKeyProfile.

int UserSettingsBoundary()
{
	UEnhancedInputUserSettings Settings;
	UPlayerMappableKeyProfile Profile;
	return Settings != nullptr || Profile != nullptr ? 1 : 0;
}
