/**
 * @version v1
 * @summary Observe FKeyEvent repeat and left/right modifier-held queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FKeyEvent repeat and left/right modifier-held queries.
 * @topic Baseline
 */
// bool KeyEvent.IsLeftShiftDown() const; bool KeyEvent.IsRightShiftDown() const;
// bool KeyEvent.IsControlDown() const; bool KeyEvent.IsLeftControlDown() const;
// bool KeyEvent.IsRightControlDown() const; bool KeyEvent.IsAltDown() const;
// bool KeyEvent.IsLeftAltDown() const; bool KeyEvent.IsRightAltDown() const;
// Inputs: A default-constructed FKeyEvent as the empty/negative modifier state.
// Expected observations: Default events report false for repeat and every
// listed modifier. True held-state bits are not reachable from the published
// default constructor.
// Boundary/ownership: Queries do not mutate the event. Modifier bits belong to
// the native event payload, not to a copied FKey.

namespace TS_InputEvents_Queries_02
{
	bool Observe_IsRepeat_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsRepeat();
	}

	bool Observe_IsShiftDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsShiftDown();
	}

	bool Observe_IsLeftShiftDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsLeftShiftDown();
	}

	bool Observe_IsRightShiftDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsRightShiftDown();
	}

	bool Observe_IsControlDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsControlDown();
	}

	bool Observe_IsLeftControlDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsLeftControlDown();
	}

	bool Observe_IsRightControlDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsRightControlDown();
	}

	bool Observe_IsAltDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsAltDown();
	}

	bool Observe_IsLeftAltDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsLeftAltDown();
	}

	bool Observe_IsRightAltDown_Nominal()
	{
		FKeyEvent KeyEvent;
		return !KeyEvent.IsRightAltDown();
	}
}
/** @end */
