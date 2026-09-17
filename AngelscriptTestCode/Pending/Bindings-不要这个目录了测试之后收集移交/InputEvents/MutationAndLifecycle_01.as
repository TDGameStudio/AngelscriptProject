/**
 * @version v1
 * @summary Observe FEventReply focus, cursor, and navigation mutation, including default-argument omission, repeated calls, and returned-reference aliasing.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FEventReply focus, cursor, and navigation mutation, including default-argument omission, repeated calls, and returned-reference aliasing.
 * @topic Baseline
 */
// EFocusCause::SetDirectly, bool bAllUsers = false);
// Reply.ClearUserFocus(bool bAllUsers = false);
// Reply.SetMousePos(const FIntPoint& NewMousePos);
// Reply.SetNavigation(EUINavigation NavigationType, ENavigationGenesis Genesis,
// ENavigationSource Source = ENavigationSource::FocusedWidget);
// Reply.SetNavigation(UWidget NavigationDestination, ENavigationGenesis Genesis,
// ENavigationSource Source = ENavigationSource::FocusedWidget);
// Inputs: FEventReply::Handled() as the seeded reply, a transient UTextBlock as
// the focus/navigation destination, FIntPoint(10,20) then (0,0), EUINavigation::Next
// and EUINavigation::Down, ENavigationGenesis::Keyboard and User, default source
// omission plus ENavigationSource::FocusedWidget, default focus cause omission
// plus EFocusCause::Mouse, and bAllUsers true/false.
// Expected observations: Each mutator returns an alias of the same reply used
// for a follow-up call. Default-argument and explicit-argument forms both
// return. Repeated SetMousePos replaces the requested desktop pixel position.
// Boundary/ownership: The reply does not take ownership of the widget. Focus
// and capture apply only when the widget already has a cached Slate widget;
// a NewObject text block is a valid null-slate no-op destination.

namespace TS_InputEvents_MutationAndLifecycle_01
{
	bool Observe_SetUserFocus_Nominal()
	{
		UWidget FocusWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.FocusWidget", true));
		if (FocusWidget is null)
		{
			throw("TS_InputEvents_MutationAndLifecycle_01 setup: required FocusWidget is null");
		}
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.SetUserFocus(FocusWidget);
		Alias.SetUserFocus(FocusWidget, EFocusCause::SetDirectly);
		Alias.SetUserFocus(FocusWidget, EFocusCause::Mouse, true);
		FEventReply& Again = Alias.SetUserFocus(FocusWidget, EFocusCause::SetDirectly, false);
		return FocusWidget.GetName() == n"TestSource.InputEvents.FocusWidget";
	}

	bool Observe_ClearUserFocus_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FEventReply& Alias = Reply.ClearUserFocus();
		Alias.ClearUserFocus(false);
		FEventReply& AllUsers = Alias.ClearUserFocus(true);
		return true;
	}

	bool Observe_SetMousePos_Nominal()
	{
		FEventReply Reply = FEventReply::Handled();
		FIntPoint Requested(10, 20);
		FEventReply& Alias = Reply.SetMousePos(Requested);
		FIntPoint Origin;
		Alias.SetMousePos(Origin);
		FIntPoint Repeat(10, 20);
		FEventReply& Again = Alias.SetMousePos(Repeat);
		return Requested.X == 10 && Requested.Y == 20 && Origin.X == 0 && Origin.Y == 0 && Repeat.X == 10;
	}

	bool Observe_SetNavigation_Nominal()
	{
		UWidget Destination = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.NavWidget", true));
		if (Destination is null)
		{
			throw("TS_InputEvents_MutationAndLifecycle_01 setup: required Destination is null");
		}
		FEventReply Reply = FEventReply::Handled();
		FEventReply& DirectionAlias = Reply.SetNavigation(EUINavigation::Next, ENavigationGenesis::Keyboard);
		DirectionAlias.SetNavigation(EUINavigation::Down, ENavigationGenesis::Controller, ENavigationSource::FocusedWidget);
		FEventReply& WidgetAlias = DirectionAlias.SetNavigation(Destination, ENavigationGenesis::User);
		WidgetAlias.SetNavigation(Destination, ENavigationGenesis::Keyboard, ENavigationSource::FocusedWidget);
		return Destination.GetName() == n"TestSource.InputEvents.NavWidget";
	}
}
/** @end */
