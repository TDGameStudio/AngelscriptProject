/**
 * A player controller's touch query surface: CaptureTouch forwards a finger
 * index into GetInputTouchState with out parameters for position and press
 * state.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.TouchStateQuerySurface
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.TouchStateQuerySurface
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::TouchStateQuerySurface
 * @Provenance sha256=4ba99b3159962d284d8ce0314d0d7bb167114e6cbdebf25a827fb64a24825040; lines 1874-1899.
 * @Provenance Oracle: ATouchStateQueryController compiles; CaptureTouch/HasTouchStateStorage reflect;
 * @Provenance TouchX/TouchY float; bTouchPressed bool; HasTouchStateStorage true at default 0/0/false.
 * @Provenance Extra: writing TouchX/TouchY/bTouchPressed is copy-independent of CaptureTouch.
 * @Provenance DefaultSafe. GetInputTouchState is the query owner.
 */

UCLASS()
class ATouchStateQueryController : APlayerController
{
	UPROPERTY()
	float32 TouchX = 0.0f;

	UPROPERTY()
	float32 TouchY = 0.0f;

	UPROPERTY()
	bool bTouchPressed = false;

	/**
	 * Queries the engine for one finger's touch state.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a finger index
	 * @Return nothing; the position and press state are stored
	 * @Param FingerIndex the finger being queried
	 */
	UFUNCTION()
	void CaptureTouch(ETouchIndex FingerIndex)
	{
		GetInputTouchState(FingerIndex, TouchX, TouchY, bTouchPressed);
	}

	/**
	 * Reports whether the storage still holds its zeroed defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three touch UPROPERTYs
	 * @Return true when position is 0,0 and not pressed
	 */
	UFUNCTION()
	bool HasTouchStateStorage()
	{
		if (TouchX != 0.0f)
		{
			return false;
		}

		if (TouchY != 0.0f)
		{
			return false;
		}

		return !bTouchPressed;
	}

	/**
	 * Observe the default zeroed storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed controller
	 * @Return true when HasTouchStateStorage holds
	 * @Boundary default values
	 */
	UFUNCTION()
	bool TouchStateQueryDefaultEmpty()
	{
		return HasTouchStateStorage();
	}

	/**
	 * Observe the written boundary of the storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three UPROPERTYs written with signed values
	 * @Return true when the writes landed and the zero check no longer holds
	 * @Boundary written values
	 */
	UFUNCTION()
	bool TouchStateQueryWrittenBoundary()
	{
		TouchX = 1.0f;
		TouchY = -1.0f;
		bTouchPressed = true;

		if (!Math::IsNearlyEqual(TouchX, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(TouchY, -1.0))
		{
			return false;
		}

		if (!bTouchPressed)
		{
			return false;
		}

		return !HasTouchStateStorage();
	}
}
