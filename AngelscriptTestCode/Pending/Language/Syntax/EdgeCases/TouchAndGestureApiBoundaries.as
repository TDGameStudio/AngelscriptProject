/**
 * @version v1
 * @summary Touch and gesture key constants reachable without a live device: the gesture trio, the Steam touch pair, and the fact that no BindTouch or BindGesture surface exists in this API generation.
 * @topic Language
 */
/**
 * @version root
 * @summary Touch and gesture key constants reachable without a live device: the gesture trio, the Steam touch pair, and the fact that no BindTouch or BindGesture surface exists in this API generation.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Checks every touch and gesture key constant for validity.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the gesture and Steam touch key constants
	 * @Return 1 when all five keys are reachable, otherwise 0
	 */
	int TouchKeyAndPointerSurface()
	{
		bool bGestureKeysAreReachable = EKeys::Gesture_Pinch.IsValid() &&
			EKeys::Gesture_Flick.IsValid() &&
			EKeys::Gesture_Rotate.IsValid();
		bool bTouchLikeControllerKeysAreReachable = EKeys::Steam_Touch_0.IsValid() &&
			EKeys::Steam_Touch_1.IsValid();
		return bGestureKeysAreReachable && bTouchLikeControllerKeysAreReachable ? 1 : 0;
	}

	/**
	 * Records that no touch binding surface exists.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int TouchBindingSurfaceIsAbsent()
	{
		return 1;
	}

	/**
	 * Observe both surface checks.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs TouchKeyAndPointerSurface and TouchBindingSurfaceIsAbsent
	 * @Return true when both report 1
	 */
	UFUNCTION()
	bool TouchAndGestureNominal()
	{
		if (TouchKeyAndPointerSurface() != 1)
		{
			return false;
		}

		return TouchBindingSurfaceIsAbsent() == 1;
	}

	/**
	 * Observe that each key validates independently.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the gesture and Steam touch keys checked separately
	 * @Return true when both sampled keys are individually valid
	 * @Boundary independent validity
	 */
	UFUNCTION()
	bool TouchAndGestureKeyIndependence()
	{
		if (!EKeys::Gesture_Pinch.IsValid())
		{
			return false;
		}

		return EKeys::Steam_Touch_0.IsValid();
	}
}
/** @end */
