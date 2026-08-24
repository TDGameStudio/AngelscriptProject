// Purpose: Observe legacy user, pointer, and touchpad indices on default and
// empty input events.
// AS-facing API: uint32 KeyEvent.GetUserIndex() const;
// uint32 PointerEvent.GetUserIndex() const;
// uint32 PointerEvent.GetPointerIndex() const;
// uint32 PointerEvent.GetTouchpadIndex() const;
// uint32 NavigationEvent.GetUserIndex() const;
// uint32 AnalogInputEvent.GetUserIndex() const;
// uint32 CharacterEvent.GetUserIndex() const;
// Inputs: Default-constructed key, pointer, navigation, analog, and character
// events as the empty index state. First valid index is 0.
// Expected observations: Empty events report user index 0. Pointer index is 0.
// Touchpad index is 0 because the bind always returns 0.
// Boundary/ownership: These queries do not mutate the event. The bind does
// not throw on the empty event; out-of-range pointer identity is not a native
// diagnostic on these getters.

namespace TS_InputEvents_IndexAndIteration_01
{
	bool Observe_GetUserIndex_Nominal()
	{
		FKeyEvent KeyEvent;
		FPointerEvent PointerEvent;
		FNavigationEvent NavigationEvent;
		FAnalogInputEvent AnalogInputEvent;
		FCharacterEvent CharacterEvent;
		return KeyEvent.GetUserIndex() == 0 &&
			PointerEvent.GetUserIndex() == 0 &&
			NavigationEvent.GetUserIndex() == 0 &&
			AnalogInputEvent.GetUserIndex() == 0 &&
			CharacterEvent.GetUserIndex() == 0;
	}

	bool Observe_GetPointerIndex_Nominal()
	{
		FPointerEvent PointerEvent;
		return PointerEvent.GetPointerIndex() == 0;
	}

	bool Observe_GetTouchpadIndex_Nominal()
	{
		FPointerEvent PointerEvent;
		return PointerEvent.GetTouchpadIndex() == 0;
	}

	void ExerciseExpectedFailure()
	{
		FPointerEvent PointerEvent;
		uint32 InvalidCompanion = PointerEvent.GetPointerIndex();
	}
}
