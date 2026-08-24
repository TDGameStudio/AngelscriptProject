// Theme: Gameplay.Input. Value oracle: UInputModifierFOVScaling stays exposed.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// Module compiles; FOVScalingIsExposed returns 1 when Modifier != nullptr.
// Extra: default-constructed modifier is the empty vector. DefaultSafe.

int FOVScalingIsExposed()
{
	UInputModifierFOVScaling Modifier;
	return Modifier != nullptr ? 1 : 0;
}

bool Observe_FOVScalingIsExposed_Nominal()
{
	return FOVScalingIsExposed() == 1;
}

int Observe_FOVScalingIsExposed_NullBoundary()
{
	UInputModifierFOVScaling Modifier = nullptr;
	return Modifier != nullptr ? 1 : 0;
}
