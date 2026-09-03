/**
 * A harness whose Bind attaches button, checkbox and editable-text handlers that
 * C++ then broadcasts. C++ compiles the class and looks up Bind plus the
 * UPROPERTY names, so those names are part of the contract and are kept
 * verbatim. The observers cover the empty default, the C++ broadcast values, an
 * unchecked boundary and the independence of two instances.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.WidgetDynamicEventsInvokeScriptHandlers
 * @Harness UClass
 * @Tag Gameplay.Widget.WidgetDynamicEventsInvokeScriptHandlers
 * @Provenance Theme: Gameplay.Widget. Positive dynamic widget events invoke AS handlers.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::WidgetDynamicEventsInvokeScriptHandlers
 * @Provenance Oracle after Bind + Broadcast: Click/Press/Release/Hover/Unhover/Check/Text counts 1,
 * @Provenance bLastChecked true, LastText "Changed".
 * @Provenance Extra: defaults 0/false/empty; false check-state boundary. DefaultSafe.
 */

UCLASS()
class UCoverageWidgetEventHarness : UObject
{
	UPROPERTY()
	int ClickCount = 0;

	UPROPERTY()
	int PressCount = 0;

	UPROPERTY()
	int ReleaseCount = 0;

	UPROPERTY()
	int HoverCount = 0;

	UPROPERTY()
	int UnhoverCount = 0;

	UPROPERTY()
	int CheckChangedCount = 0;

	UPROPERTY()
	int TextChangedCount = 0;

	UPROPERTY()
	bool bLastChecked = false;

	UPROPERTY()
	FString LastText;

	/**
	 * Bind button, checkbox and text events onto this harness.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs a button, a checkbox and an editable text
	 * @Return none; AddUFunction on clicked, pressed, released, hovered, unhovered, check and text
	 * @Param Button the button
	 * @Param CheckBox the checkbox
	 * @Param Editable the editable text
	 */
	UFUNCTION()
	void Bind(UButton Button, UCheckBox CheckBox, UEditableText Editable)
	{
		Button.OnClicked.AddUFunction(this, n"HandleClicked");
		Button.OnPressed.AddUFunction(this, n"HandlePressed");
		Button.OnReleased.AddUFunction(this, n"HandleReleased");
		Button.OnHovered.AddUFunction(this, n"HandleHovered");
		Button.OnUnhovered.AddUFunction(this, n"HandleUnhovered");
		CheckBox.OnCheckStateChanged.AddUFunction(this, n"HandleCheckStateChanged");
		Editable.OnTextChanged.AddUFunction(this, n"HandleTextChanged");
	}

	/**
	 * Record a button clicked event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return ClickCount incremented
	 */
	UFUNCTION()
	void HandleClicked()
	{
		ClickCount += 1;
	}

	/**
	 * Record a button pressed event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return PressCount incremented
	 */
	UFUNCTION()
	void HandlePressed()
	{
		PressCount += 1;
	}

	/**
	 * Record a button released event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return ReleaseCount incremented
	 */
	UFUNCTION()
	void HandleReleased()
	{
		ReleaseCount += 1;
	}

	/**
	 * Record a button hovered event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return HoverCount incremented
	 */
	UFUNCTION()
	void HandleHovered()
	{
		HoverCount += 1;
	}

	/**
	 * Record a button unhovered event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return UnhoverCount incremented
	 */
	UFUNCTION()
	void HandleUnhovered()
	{
		UnhoverCount += 1;
	}

	/**
	 * Record a checkbox check-state event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the new checked flag
	 * @Return CheckChangedCount incremented and bLastChecked updated
	 * @Param bChecked the new checked flag
	 */
	UFUNCTION()
	void HandleCheckStateChanged(bool bChecked)
	{
		CheckChangedCount += 1;
		bLastChecked = bChecked;
	}

	/**
	 * Record an editable-text changed event.
	 *
	 * @Kind Action
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the new text
	 * @Return TextChangedCount incremented and LastText updated
	 * @Param Text the new text
	 */
	UFUNCTION()
	void HandleTextChanged(const FText&in Text)
	{
		TextChangedCount += 1;
		LastText = Text.ToString();
	}

	/**
	 * Observe that an untouched harness has no events.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return true when all counts are 0, bLastChecked is false and LastText is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ClickCount != 0)
		{
			return false;
		}
		if (PressCount != 0)
		{
			return false;
		}
		if (ReleaseCount != 0)
		{
			return false;
		}
		if (HoverCount != 0)
		{
			return false;
		}
		if (UnhoverCount != 0)
		{
			return false;
		}
		if (CheckChangedCount != 0)
		{
			return false;
		}
		if (TextChangedCount != 0)
		{
			return false;
		}
		if (bLastChecked)
		{
			return false;
		}
		return LastText.Len() == 0;
	}

	/**
	 * Observe that the C++ broadcast values land on this harness.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the click, press, release, hover, unhover, checked and text values C++ broadcasts
	 * @Return true when every count is 1, bLastChecked is true and LastText is Changed
	 */
	UFUNCTION()
	bool BroadcastValues()
	{
		HandleClicked();
		HandlePressed();
		HandleReleased();
		HandleHovered();
		HandleUnhovered();
		HandleCheckStateChanged(true);
		HandleTextChanged(FText::FromString("Changed"));

		if (ClickCount != 1)
		{
			return false;
		}
		if (PressCount != 1)
		{
			return false;
		}
		if (ReleaseCount != 1)
		{
			return false;
		}
		if (HoverCount != 1)
		{
			return false;
		}
		if (UnhoverCount != 1)
		{
			return false;
		}
		if (CheckChangedCount != 1)
		{
			return false;
		}
		if (!bLastChecked)
		{
			return false;
		}
		if (TextChangedCount != 1)
		{
			return false;
		}
		return LastText == "Changed";
	}

	/**
	 * Observe that an unchecked broadcast stores false.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs a false check-state
	 * @Return true when the count is 1 and bLastChecked is false
	 * @Boundary false check-state
	 */
	UFUNCTION()
	bool UncheckedBoundary()
	{
		HandleCheckStateChanged(false);

		if (CheckChangedCount != 1)
		{
			return false;
		}
		return bLastChecked == false;
	}

	/**
	 * Observe that writing this harness leaves another harness at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs a second harness
	 * @Return true when this records a click and the other still reads 0
	 * @Param Second the other harness, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageWidgetEventHarness Second)
	{
		if (Second is null)
		{
			throw("WidgetDynamicEventsInvokeScriptHandlers setup: required Second is null");
		}
		HandleClicked();

		if (ClickCount != 1)
		{
			return false;
		}
		return Second.ClickCount == 0;
	}
}
