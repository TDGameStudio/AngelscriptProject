/**
 * Touch and gesture key constants reachable without a live device: the gesture
 * trio, the Steam touch pair, and the fact that no BindTouch or BindGesture
 * surface exists in this API generation.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.TouchAndGestureApiBoundaries
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.TouchAndGestureApiBoundaries
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::TouchAndGestureApiBoundaries ExecuteAndExpectInt
 * @Provenance sha256=a3047a53829667ba5a0e5262dbf490ae06748f9b26540b4b54aaa4577621243d; lines 1580-1595.
 * @Provenance Oracle: TouchKeyAndPointerSurface() == 1; TouchBindingSurfaceIsAbsent() == 1.
 * @Provenance Extra: each gesture key IsValid independently; Steam_Touch_0 empty-device still valid as a key id.
 * @Provenance DefaultSafe. Source owns locals. No BindTouch/BindGesture APIs in this block.
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
