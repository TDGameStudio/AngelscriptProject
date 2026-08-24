// Theme: Gameplay.Input. Isolated compile-fail: GetInputAxisValue by action name.
// C++: AngelscriptCoverageInputTests.cpp::InputStateQuery
// CompileAndExpectFailure diagnostic contains GetInputAxisValue.
// CSV Positive; C++ does not compile. DiagnosticOnly.
// Do not add extra declarations that would compile this away. Keep n"" FNames.

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
