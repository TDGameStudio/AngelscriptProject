// Theme: Gameplay.Widget. Positive dynamic widget events invoke AS handlers.
// C++: AngelscriptCoverageWidgetTests.cpp::WidgetDynamicEventsInvokeScriptHandlers
// Oracle after Bind + Broadcast: Click/Press/Release/Hover/Unhover/Check/Text counts 1,
// bLastChecked true, LastText "Changed".
// Extra: defaults 0/false/empty; false check-state boundary. DefaultSafe.

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

	UFUNCTION()
	void HandleClicked()
	{
		ClickCount += 1;
	}

	UFUNCTION()
	void HandlePressed()
	{
		PressCount += 1;
	}

	UFUNCTION()
	void HandleReleased()
	{
		ReleaseCount += 1;
	}

	UFUNCTION()
	void HandleHovered()
	{
		HoverCount += 1;
	}

	UFUNCTION()
	void HandleUnhovered()
	{
		UnhoverCount += 1;
	}

	UFUNCTION()
	void HandleCheckStateChanged(bool bChecked)
	{
		CheckChangedCount += 1;
		bLastChecked = bChecked;
	}

	UFUNCTION()
	void HandleTextChanged(const FText&in Text)
	{
		TextChangedCount += 1;
		LastText = Text.ToString();
	}
}

bool Observe_WidgetDynamicEvents_DefaultEmpty(UCoverageWidgetEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_WidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	return Harness.ClickCount == 0
		&& Harness.PressCount == 0
		&& Harness.ReleaseCount == 0
		&& Harness.HoverCount == 0
		&& Harness.UnhoverCount == 0
		&& Harness.CheckChangedCount == 0
		&& Harness.TextChangedCount == 0
		&& Harness.bLastChecked == false
		&& Harness.LastText.Len() == 0;
}

bool Observe_WidgetDynamicEvents_CppBroadcastValues(UCoverageWidgetEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_WidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	Harness.HandleClicked();
	Harness.HandlePressed();
	Harness.HandleReleased();
	Harness.HandleHovered();
	Harness.HandleUnhovered();
	Harness.HandleCheckStateChanged(true);
	Harness.HandleTextChanged(FText::FromString("Changed"));
	return Harness.ClickCount == 1
		&& Harness.PressCount == 1
		&& Harness.ReleaseCount == 1
		&& Harness.HoverCount == 1
		&& Harness.UnhoverCount == 1
		&& Harness.CheckChangedCount == 1
		&& Harness.bLastChecked == true
		&& Harness.TextChangedCount == 1
		&& Harness.LastText == "Changed";
}

bool Observe_WidgetDynamicEvents_UncheckedBoundary(UCoverageWidgetEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_WidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	Harness.HandleCheckStateChanged(false);
	return Harness.CheckChangedCount == 1 && Harness.bLastChecked == false;
}
