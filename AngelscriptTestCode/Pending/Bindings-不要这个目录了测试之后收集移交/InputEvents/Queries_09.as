/**
 * @version v1
 * @summary Observe FCharacterEvent shift, control, alt, and command held-state queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FCharacterEvent shift, control, alt, and command held-state queries.
 * @topic Baseline
 */
// bool CharacterEvent.IsLeftShiftDown() const;
// bool CharacterEvent.IsRightShiftDown() const;
// bool CharacterEvent.IsControlDown() const;
// bool CharacterEvent.IsLeftControlDown() const;
// bool CharacterEvent.IsRightControlDown() const;
// bool CharacterEvent.IsAltDown() const; bool CharacterEvent.IsLeftAltDown() const;
// bool CharacterEvent.IsRightAltDown() const;
// bool CharacterEvent.IsCommandDown() const;
// Inputs: A default-constructed FCharacterEvent as the empty/negative modifier
// state.
// Expected observations: Every listed modifier query is false on the empty
// character event. True held-state bits are not reachable from the published
// default constructor.
// Boundary/ownership: Queries do not mutate the character event.

namespace TS_InputEvents_Queries_09
{
	bool Observe_IsShiftDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsShiftDown();
	}

	bool Observe_IsLeftShiftDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsLeftShiftDown();
	}

	bool Observe_IsRightShiftDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsRightShiftDown();
	}

	bool Observe_IsControlDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsControlDown();
	}

	bool Observe_IsLeftControlDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsLeftControlDown();
	}

	bool Observe_IsRightControlDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsRightControlDown();
	}

	bool Observe_IsAltDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsAltDown();
	}

	bool Observe_IsLeftAltDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsLeftAltDown();
	}

	bool Observe_IsRightAltDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsRightAltDown();
	}

	bool Observe_IsCommandDown_Nominal()
	{
		FCharacterEvent CharacterEvent;
		return !CharacterEvent.IsCommandDown();
	}
}
/** @end */
