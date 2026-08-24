// Theme: Language.Syntax.EdgeCases. Positive: player-controller touch query storage.
// C++: AngelscriptCoverageInputTests.cpp::TouchStateQuerySurface
// sha256=4ba99b3159962d284d8ce0314d0d7bb167114e6cbdebf25a827fb64a24825040; lines 1874-1899.
// Oracle: ATouchStateQueryController compiles; CaptureTouch/HasTouchStateStorage reflect;
// TouchX/TouchY float; bTouchPressed bool; HasTouchStateStorage true at default 0/0/false.
// Extra: writing TouchX/TouchY/bTouchPressed is copy-independent of CaptureTouch.
// DefaultSafe. GetInputTouchState is the query owner.

UCLASS()
class ATouchStateQueryController : APlayerController
{
	UPROPERTY()
	float32 TouchX = 0.0f;

	UPROPERTY()
	float32 TouchY = 0.0f;

	UPROPERTY()
	bool bTouchPressed = false;

	UFUNCTION()
	void CaptureTouch(ETouchIndex FingerIndex)
	{
		GetInputTouchState(FingerIndex, TouchX, TouchY, bTouchPressed);
	}

	UFUNCTION()
	bool HasTouchStateStorage()
	{
		return TouchX == 0.0f && TouchY == 0.0f && !bTouchPressed;
	}
}

bool Observe_TouchStateQuery_DefaultEmpty(ATouchStateQueryController Controller)
{
	if (Controller is null)
	{
		throw("Test_TouchStateQuerySurface setup: required Controller is null");
	}
	return Controller.HasTouchStateStorage();
}

bool Observe_TouchStateQuery_WrittenBoundary(ATouchStateQueryController Controller)
{
	if (Controller is null)
	{
		throw("Test_TouchStateQuerySurface setup: required Controller is null");
	}
	Controller.TouchX = 1.0f;
	Controller.TouchY = -1.0f;
	Controller.bTouchPressed = true;
	return Controller.TouchX == 1.0f && Controller.TouchY == -1.0f && Controller.bTouchPressed && !Controller.HasTouchStateStorage();
}
