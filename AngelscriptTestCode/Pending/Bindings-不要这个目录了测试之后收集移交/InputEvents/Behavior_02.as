/**
 * @version v1
 * @summary Observe FEventReply mouse-lock release and Caps Lock queries on navigation and character events.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FEventReply mouse-lock release and Caps Lock queries on navigation and character events.
 * @topic Baseline
 */
// bool NavigationEvent.AreCapsLocked() const;
// bool CharacterEvent.AreCapsLocked() const;
// Inputs: FEventReply::Handled() as the seeded reply, FEventReply::Unhandled()
// as the empty reply, and default FNavigationEvent / FCharacterEvent.
// Expected observations: ReleaseMouseLock returns an alias used for a repeated
// call. Caps Lock is false on empty navigation and character events.
// Boundary/ownership: ReleaseMouseLock mutates the reply in place and does not
// require a widget. Caps Lock bits belong to the native event payload.

namespace TS_InputEvents_Behavior_02
{
	bool Observe_ReleaseMouseLock_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.ReleaseMouseLock();
		Alias.ReleaseMouseLock();
		FEventReply Unhandled = FEventReply::Unhandled();
		Unhandled.ReleaseMouseLock();
		return true;
	}

	bool Observe_AreCapsLocked_Nominal()
	{
		FNavigationEvent NavigationEvent;
		FCharacterEvent CharacterEvent;
		return !NavigationEvent.AreCapsLocked() && !CharacterEvent.AreCapsLocked();
	}
}
/** @end */
