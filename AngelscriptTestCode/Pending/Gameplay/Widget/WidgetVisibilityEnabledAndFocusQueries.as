/**
 * @version v1
 * @summary Widget visibility, enabled-state and keyboard-focus queries. C++ executes each helper and expects 1, so those names are part of the contract and are kept verbatim. A null widget refuses SetAndReadVisibility.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Widget visibility, enabled-state and keyboard-focus queries. C++ executes each helper and expects 1, so those names are part of the contract and are kept verbatim. A null widget refuses SetAndReadVisibility.
 * @topic Baseline
 */
namespace WidgetTest
{
	/**
	 * Write a visibility and read it back.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs a widget and a visibility
	 * @Return true when GetVisibility matches; false when the widget is null
	 * @Param Widget the widget to write
	 * @Param Visibility the visibility to apply
	 */
	UFUNCTION()
	bool SetAndReadVisibility(UWidget Widget, ESlateVisibility Visibility)
	{
		if (Widget == null)
		{
			return false;
		}

		Widget.SetVisibility(Visibility);
		return Widget.GetVisibility() == Visibility;
	}

	/**
	 * Round-trip every ESlateVisibility value on a button.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs a button from MakeWidget
	 * @Return 1 when every value reads back; 0 on a missed MakeWidget; 10/20/30/40/50 naming the miss
	 */
	UFUNCTION()
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

	/**
	 * Disable then enable a button and read the flag back.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs a button from MakeWidget
	 * @Return 1 when the flag reads true; 0 on a missed MakeWidget; 10 when disable fails; 20 when enable fails
	 */
	UFUNCTION()
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

	/**
	 * Query HasKeyboardFocus on a headless button.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs a button from MakeWidget
	 * @Return 1 when focus is false; 2 when it is true; 0 on a missed MakeWidget
	 */
	UFUNCTION()
	int KeyboardFocusQueryIsCallable()
	{
		UWidget Widget = MakeWidget(UButton::StaticClass(), n"FocusProbe");
		if (Widget == null)
		{
			return 0;
		}

		return Widget.HasKeyboardFocus() ? 2 : 1;
	}

	/**
	 * Observe that the headless focus query reports no keyboard focus.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs none
	 * @Return true when KeyboardFocusQueryIsCallable returns 1
	 * @Boundary headless
	 */
	UFUNCTION()
	bool KeyboardFocusQueryHeadless()
	{
		return KeyboardFocusQueryIsCallable() == 1;
	}

	/**
	 * Observe that a null widget refuses a visibility write.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetVisibilityEnabledAndFocusQueries
	 * @Inputs a null widget
	 * @Return true when SetAndReadVisibility returns false
	 * @Boundary null widget
	 */
	UFUNCTION()
	bool SetAndReadVisibilityNullWidget()
	{
		return SetAndReadVisibility(nullptr, ESlateVisibility::Visible) == false;
	}
}
/** @end */
