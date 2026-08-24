// Purpose: Observe FPointerEvent touch-force and touch-kind queries plus
// FNavigationEvent repeat and shift/control held-state queries.
// AS-facing API: float32 PointerEvent.GetTouchForce() const;
// bool PointerEvent.IsTouchEvent() const;
// bool PointerEvent.IsTouchForceChangedEvent() const;
// bool PointerEvent.IsTouchFirstMoveEvent() const;
// bool PointerEvent.IsDirectionInvertedFromDevice() const;
// bool NavigationEvent.IsRepeat() const; bool NavigationEvent.IsShiftDown() const;
// bool NavigationEvent.IsLeftShiftDown() const;
// bool NavigationEvent.IsRightShiftDown() const;
// bool NavigationEvent.IsControlDown() const;
// Inputs: Default FPointerEvent and FNavigationEvent as empty receivers.
// Expected observations: Touch force is 1 on the default FPointerEvent.
// Touch/kind/invert flags are false. Navigation repeat and modifier bits
// are false.
// Boundary/ownership: Touch force is normalized device payload. Queries do
// not mutate either event.

namespace TS_InputEvents_Queries_06
{
	bool Observe_GetTouchForce_Nominal()
	{
		FPointerEvent PointerEvent;
		return PointerEvent.GetTouchForce() == 1.0;
	}

	bool Observe_IsTouchEvent_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsTouchEvent();
	}

	bool Observe_IsTouchForceChangedEvent_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsTouchForceChangedEvent();
	}

	bool Observe_IsTouchFirstMoveEvent_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsTouchFirstMoveEvent();
	}

	bool Observe_IsDirectionInvertedFromDevice_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsDirectionInvertedFromDevice();
	}

	bool Observe_IsRepeat_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsRepeat();
	}

	bool Observe_IsShiftDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsShiftDown();
	}

	bool Observe_IsLeftShiftDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsLeftShiftDown();
	}

	bool Observe_IsRightShiftDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsRightShiftDown();
	}

	bool Observe_IsControlDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsControlDown();
	}
}
