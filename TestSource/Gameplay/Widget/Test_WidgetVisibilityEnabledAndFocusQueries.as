// Theme: Gameplay.Widget. Positive visibility / enabled / focus round-trips.
// C++: AngelscriptCoverageWidgetTests.cpp::WidgetVisibilityEnabledAndFocusQueries
// Oracle ExecuteBatchAndExpectInt: VisibilityEnumRoundTrip 1, EnabledRoundTrip 1,
// KeyboardFocusQueryIsCallable 1 (HasKeyboardFocus false in headless).
// Extra: SetAndReadVisibility(null) false. DefaultSafe.

bool SetAndReadVisibility(UWidget Widget, ESlateVisibility Visibility)
{
	if (Widget == null)
	{
		return false;
	}

	Widget.SetVisibility(Visibility);
	return Widget.GetVisibility() == Visibility;
}

int VisibilityEnumRoundTrip()
{
	UWidget Widget = MakeWidget(UButton::StaticClass(), n"VisibilityProbe");
	if (Widget == null)
	{
		return 0;
	}

	if (!SetAndReadVisibility(Widget, ESlateVisibility::Visible))
	{
		return 10;
	}
	if (!SetAndReadVisibility(Widget, ESlateVisibility::Collapsed))
	{
		return 20;
	}
	if (!SetAndReadVisibility(Widget, ESlateVisibility::Hidden))
	{
		return 30;
	}
	if (!SetAndReadVisibility(Widget, ESlateVisibility::HitTestInvisible))
	{
		return 40;
	}
	if (!SetAndReadVisibility(Widget, ESlateVisibility::SelfHitTestInvisible))
	{
		return 50;
	}

	return 1;
}

int EnabledRoundTrip()
{
	UWidget Widget = MakeWidget(UButton::StaticClass(), n"EnabledProbe");
	if (Widget == null)
	{
		return 0;
	}

	Widget.SetIsEnabled(false);
	if (Widget.GetIsEnabled())
	{
		return 10;
	}

	Widget.SetIsEnabled(true);
	return Widget.GetIsEnabled() ? 1 : 20;
}

int KeyboardFocusQueryIsCallable()
{
	UWidget Widget = MakeWidget(UButton::StaticClass(), n"FocusProbe");
	if (Widget == null)
	{
		return 0;
	}

	return Widget.HasKeyboardFocus() ? 2 : 1;
}

bool Observe_VisibilityEnumRoundTrip_Nominal()
{
	return VisibilityEnumRoundTrip() == 1;
}

bool Observe_EnabledRoundTrip_Nominal()
{
	return EnabledRoundTrip() == 1;
}

bool Observe_KeyboardFocusQuery_Headless()
{
	return KeyboardFocusQueryIsCallable() == 1;
}

bool Observe_SetAndReadVisibility_NullWidget()
{
	return SetAndReadVisibility(nullptr, ESlateVisibility::Visible) == false;
}
