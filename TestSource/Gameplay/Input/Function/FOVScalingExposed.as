/**
 * Value oracle: UInputModifierFOVScaling stays exposed. C++ compiles the module
 * ASCoverageInput_FOVScalingExposed; FOVScalingIsExposed returns 1 when the
 * modifier is not null. The observers cover the positive result and an explicit
 * null handle.
 *
 * @Theme Gameplay.Input
 * @Subject Input.FOVScalingExposed
 * @Harness Function
 * @Tag Gameplay.Input.FOVScalingExposed
 * @Namespace InputTest
 * @Provenance Theme: Gameplay.Input. Value oracle: UInputModifierFOVScaling stays exposed.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance Module compiles; FOVScalingIsExposed returns 1 when Modifier != nullptr.
 * @Provenance Extra: default-constructed modifier is the empty vector. DefaultSafe.
 */

namespace InputTest
{
	/**
	 * The entrypoint C++ compiles, returning 1 when a default FOV-scaling modifier is live.
	 *
	 * @Kind Observe
	 * @Covers Input.FOVScalingExposed
	 * @Inputs none
	 * @Return 1 when the modifier is not null
	 */
	UFUNCTION()
	int FOVScalingIsExposed()
	{
		UInputModifierFOVScaling Modifier;
		return Modifier != nullptr ? 1 : 0;
	}

	/**
	 * Observe that the exposed modifier scores 1.
	 *
	 * @Kind Observe
	 * @Covers Input.FOVScalingExposed
	 * @Inputs none
	 * @Return true when FOVScalingIsExposed returns 1
	 */
	UFUNCTION()
	bool FOVScalingIsExposedPositive()
	{
		return FOVScalingIsExposed() == 1;
	}

	/**
	 * Observe that an explicit null modifier handle is not live.
	 *
	 * @Kind Observe
	 * @Covers Input.FOVScalingExposed
	 * @Inputs a null UInputModifierFOVScaling
	 * @Return 0 when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	int FOVScalingIsExposedNullBoundary()
	{
		UInputModifierFOVScaling Modifier = nullptr;
		return Modifier != nullptr ? 1 : 0;
	}
}
