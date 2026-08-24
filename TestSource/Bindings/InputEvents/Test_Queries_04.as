// Purpose: Observe FPointerEvent left/right shift, control, alt, and command
// held-state queries.
// AS-facing API: bool PointerEvent.IsLeftShiftDown() const;
// bool PointerEvent.IsRightShiftDown() const; bool PointerEvent.IsControlDown() const;
// bool PointerEvent.IsLeftControlDown() const; bool PointerEvent.IsRightControlDown() const;
// bool PointerEvent.IsAltDown() const; bool PointerEvent.IsLeftAltDown() const;
// bool PointerEvent.IsRightAltDown() const; bool PointerEvent.IsCommandDown() const;
// bool PointerEvent.IsLeftCommandDown() const;
// Inputs: A default-constructed FPointerEvent as the empty/negative modifier
// state.
// Expected observations: Every listed modifier query is false on the empty
// pointer event. True held-state bits are not reachable from the published
// default constructor.
// Boundary/ownership: Queries do not mutate the pointer event.

namespace TS_InputEvents_Queries_04
{
	bool Observe_IsLeftShiftDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsLeftShiftDown();
	}

	bool Observe_IsRightShiftDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsRightShiftDown();
	}

	bool Observe_IsControlDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsControlDown();
	}

	bool Observe_IsLeftControlDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsLeftControlDown();
	}

	bool Observe_IsRightControlDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsRightControlDown();
	}

	bool Observe_IsAltDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsAltDown();
	}

	bool Observe_IsLeftAltDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsLeftAltDown();
	}

	bool Observe_IsRightAltDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsRightAltDown();
	}

	bool Observe_IsCommandDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsCommandDown();
	}

	bool Observe_IsLeftCommandDown_Nominal()
	{
		FPointerEvent PointerEvent;
		return !PointerEvent.IsLeftCommandDown();
	}
}
