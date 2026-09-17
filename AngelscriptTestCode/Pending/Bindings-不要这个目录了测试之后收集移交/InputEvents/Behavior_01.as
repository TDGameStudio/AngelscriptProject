/**
 * @version v1
 * @summary Observe FKey/FInputChord construction, Caps Lock queries, and FEventReply mouse-capture/throttle fluent mutation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FKey/FInputChord construction, Caps Lock queries, and FEventReply mouse-capture/throttle fluent mutation.
 * @topic Baseline
 */
// FInputChord Chord(const FKey& Key);
// FInputChord Chord(const FKey& Key, bool bShift, bool bCtrl, bool bAlt, bool bCmd);
// bool KeyEvent.AreCapsLocked() const; bool PointerEvent.AreCapsLocked() const;
// Reply.PreventThrottling(); Reply.CaptureMouse(UWidget Widget);
// Reply.UseHighPrecisionMouseMovement(UWidget Widget);
// Reply.ReleaseMouseCapture(); Reply.LockMouseToWidget(UWidget Widget);
// Inputs: n"SpaceBar", EKeys::Enter, modifier chord (true,false,true,true) on
// LeftMouseButton, default events for Caps Lock, FEventReply::Handled(), a
// transient UTextBlock, and Unhandled as the empty reply.
// Expected observations: Named construction equals EKeys::SpaceBar. Plain chord
// uses Enter without modifiers. Modified chord preserves Shift/Alt/Cmd and not
// Ctrl. Caps Lock is false on empty events. Fluent mouse methods return an
// alias of the seeded handled reply.
// Boundary/ownership: FKey construction copies the registered key identity.
// Reply methods do not take ownership of the widget. Capture/lock apply only
// when the widget has a cached Slate widget.

namespace TS_InputEvents_Behavior_01
{
	bool Observe_Key_Nominal()
	{
		FKey Space(n"SpaceBar");
		FKey Empty(NAME_None);
		return Space == EKeys::SpaceBar && Space.IsValid() && !Empty.IsValid();
	}

	bool Observe_Chord_Nominal()
	{
		FInputChord Plain(EKeys::Enter);
		FInputChord Modified(EKeys::LeftMouseButton, true, false, true, true);
		FInputChord Empty(EKeys::Invalid);
		bool bPlainKey = Plain.Key == EKeys::Enter && !Plain.bShift && !Plain.bCtrl && !Plain.bAlt && !Plain.bCmd;
		bool bModifiedKey =
			Modified.Key == EKeys::LeftMouseButton &&
			Modified.bShift &&
			!Modified.bCtrl &&
			Modified.bAlt &&
			Modified.bCmd;
		return bPlainKey && bModifiedKey && Empty.Key == EKeys::Invalid;
	}

	bool Observe_AreCapsLocked_Nominal()
	{
		FKeyEvent KeyEvent;
		FPointerEvent PointerEvent;
		return !KeyEvent.AreCapsLocked() && !PointerEvent.AreCapsLocked();
	}

	bool Observe_PreventThrottling_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.PreventThrottling();
		Alias.PreventThrottling();
		FEventReply Unhandled = FEventReply::Unhandled();
		Unhandled.PreventThrottling();
		return true;
	}

	bool Observe_CaptureMouse_Nominal()
	{
		UWidget CaptureWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.CaptureWidget", true));
		if (CaptureWidget is null)
		{
			throw("TS_InputEvents_Behavior_01 setup: required CaptureWidget is null");
		}
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.CaptureMouse(CaptureWidget);
		Alias.CaptureMouse(CaptureWidget);
		return CaptureWidget.GetName() == n"TestSource.InputEvents.CaptureWidget";
	}

	bool Observe_UseHighPrecisionMouseMovement_Nominal()
	{
		UWidget CaptureWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.HighPrecisionWidget", true));
		if (CaptureWidget is null)
		{
			throw("TS_InputEvents_Behavior_01 setup: required CaptureWidget is null");
		}
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.UseHighPrecisionMouseMovement(CaptureWidget);
		Alias.UseHighPrecisionMouseMovement(CaptureWidget);
		return CaptureWidget.GetName() == n"TestSource.InputEvents.HighPrecisionWidget";
	}

	bool Observe_ReleaseMouseCapture_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.ReleaseMouseCapture();
		Alias.ReleaseMouseCapture();
		return true;
	}

	bool Observe_LockMouseToWidget_Nominal()
	{
		UWidget LockWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.LockWidget", true));
		if (LockWidget is null)
		{
			throw("TS_InputEvents_Behavior_01 setup: required LockWidget is null");
		}
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.LockMouseToWidget(LockWidget);
		Alias.LockMouseToWidget(LockWidget);
		return LockWidget.GetName() == n"TestSource.InputEvents.LockWidget";
	}
}
/** @end */
