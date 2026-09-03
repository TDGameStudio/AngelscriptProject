/**
 * Isolated compile-fail: GetInputAxisValue by action name. C++ compiles this as
 * the module ASCoverageInput_StateQuery and expects a diagnostic containing
 * GetInputAxisValue. Do not add extra declarations that would compile this away.
 *
 * @Theme Gameplay.Input
 * @Subject Input.InputStateQuery
 * @Harness CompileReject
 * @Tag Gameplay.Input.InputStateQuery
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: GetInputAxisValue by action name.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputStateQuery
 * @Provenance CompileAndExpectFailure diagnostic contains GetInputAxisValue.
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly.
 * @Provenance Do not add extra declarations that would compile this away. Keep n"" FNames.
 */

UCLASS()
class AInputQueryController : APlayerController
{
	UPROPERTY()
	bool WKeyDown = false;

	UPROPERTY()
	bool SpaceJustPressed = false;

	UPROPERTY()
	bool SpaceJustReleased = false;

	UPROPERTY()
	float MoveForwardAxisValue = 0.0f;

	UPROPERTY()
	float KeyDownTime = 0.0f;

	/**
	 * The isolated failing program: GetInputAxisValue by action name has no matching signature.
	 *
	 * @Kind CompileReject
	 * @Covers Input.InputStateQuery
	 * @Inputs none
	 * @Return does not compile; diagnostic contains GetInputAxisValue
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		// Query input key states
		WKeyDown = IsInputKeyDown(EKeys::W);
		SpaceJustPressed = WasInputKeyJustPressed(EKeys::SpaceBar);
		SpaceJustReleased = WasInputKeyJustReleased(EKeys::SpaceBar);

		// Query axis value
		MoveForwardAxisValue = GetInputAxisValue(n"MoveForward");

		// Query key hold time
		KeyDownTime = GetInputKeyTimeDown(EKeys::W);
	}
}
