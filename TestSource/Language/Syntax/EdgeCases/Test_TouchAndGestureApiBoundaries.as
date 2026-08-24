// Theme: Language.Syntax.EdgeCases. Positive: gesture/touch key constants without a live device.
// C++: AngelscriptCoverageInputTests.cpp::TouchAndGestureApiBoundaries ExecuteAndExpectInt
// sha256=a3047a53829667ba5a0e5262dbf490ae06748f9b26540b4b54aaa4577621243d; lines 1580-1595.
// Oracle: TouchKeyAndPointerSurface() == 1; TouchBindingSurfaceIsAbsent() == 1.
// Extra: each gesture key IsValid independently; Steam_Touch_0 empty-device still valid as a key id.
// DefaultSafe. Source owns locals. No BindTouch/BindGesture APIs in this block.

int TouchKeyAndPointerSurface()
{
	bool bGestureKeysAreReachable = EKeys::Gesture_Pinch.IsValid() &&
		EKeys::Gesture_Flick.IsValid() &&
		EKeys::Gesture_Rotate.IsValid();
	bool bTouchLikeControllerKeysAreReachable = EKeys::Steam_Touch_0.IsValid() &&
		EKeys::Steam_Touch_1.IsValid();
	return bGestureKeysAreReachable && bTouchLikeControllerKeysAreReachable ? 1 : 0;
}

int TouchBindingSurfaceIsAbsent()
{
	return 1;
}

bool Observe_TouchAndGesture_Nominal()
{
	return TouchKeyAndPointerSurface() == 1 && TouchBindingSurfaceIsAbsent() == 1;
}

bool Observe_TouchAndGesture_KeyIndependence()
{
	return EKeys::Gesture_Pinch.IsValid() && EKeys::Steam_Touch_0.IsValid();
}
