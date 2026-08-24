// Theme: Gameplay.Widget. Positive additional dynamic events (commit / slider / combo).
// C++: AngelscriptCoverageWidgetTests.cpp::AdditionalWidgetDynamicEventsInvokeScriptHandlers
// Oracle after Bind + Broadcast: TextCommittedCount 1, LastCommittedText "Committed",
// LastCommitMethod int(ETextCommit::OnEnter), SliderChangedCount 1, LastSliderValue 0.625,
// ComboSelectionChangedCount 1, LastSelectedItem "High",
// LastSelectionType int(ESelectInfo::OnMouseClick).
// Extra: defaults 0 / empty / -1; empty selected item. DefaultSafe.

UCLASS()
class UCoverageWidgetAdditionalEventHarness : UObject
{
	UPROPERTY()
	int TextCommittedCount = 0;

	UPROPERTY()
	int SliderChangedCount = 0;

	UPROPERTY()
	int ComboSelectionChangedCount = 0;

	UPROPERTY()
	FString LastCommittedText;

	UPROPERTY()
	int LastCommitMethod = -1;

	UPROPERTY()
	float LastSliderValue = 0.0f;

	UPROPERTY()
	FString LastSelectedItem;

	UPROPERTY()
	int LastSelectionType = -1;

	UFUNCTION()
	void Bind(UEditableText Editable, USlider Slider, UComboBoxString Combo)
	{
		Editable.OnTextCommitted.AddUFunction(this, n"HandleTextCommitted");
		Slider.OnValueChanged.AddUFunction(this, n"HandleSliderValueChanged");
		Combo.OnSelectionChanged.AddUFunction(this, n"HandleSelectionChanged");
	}

	UFUNCTION()
	void HandleTextCommitted(const FText&in Text, ETextCommit CommitMethod)
	{
		TextCommittedCount += 1;
		LastCommittedText = Text.ToString();
		LastCommitMethod = int(CommitMethod);
	}

	UFUNCTION()
	void HandleSliderValueChanged(float32 Value)
	{
		SliderChangedCount += 1;
		LastSliderValue = Value;
	}

	UFUNCTION()
	void HandleSelectionChanged(FString SelectedItem, ESelectInfo SelectionType)
	{
		ComboSelectionChangedCount += 1;
		LastSelectedItem = SelectedItem;
		LastSelectionType = int(SelectionType);
	}
}

bool Observe_AdditionalWidgetEvents_DefaultEmpty(UCoverageWidgetAdditionalEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	return Harness.TextCommittedCount == 0
		&& Harness.SliderChangedCount == 0
		&& Harness.ComboSelectionChangedCount == 0
		&& Harness.LastCommittedText.Len() == 0
		&& Harness.LastCommitMethod == -1
		&& Harness.LastSliderValue == 0.0f
		&& Harness.LastSelectedItem.Len() == 0
		&& Harness.LastSelectionType == -1;
}

bool Observe_AdditionalWidgetEvents_CppBroadcastValues(UCoverageWidgetAdditionalEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	Harness.HandleTextCommitted(FText::FromString("Committed"), ETextCommit::OnEnter);
	Harness.HandleSliderValueChanged(0.625f);
	Harness.HandleSelectionChanged("High", ESelectInfo::OnMouseClick);
	return Harness.TextCommittedCount == 1
		&& Harness.LastCommittedText == "Committed"
		&& Harness.LastCommitMethod == int(ETextCommit::OnEnter)
		&& Harness.SliderChangedCount == 1
		&& Harness.LastSliderValue == 0.625f
		&& Harness.ComboSelectionChangedCount == 1
		&& Harness.LastSelectedItem == "High"
		&& Harness.LastSelectionType == int(ESelectInfo::OnMouseClick);
}

bool Observe_AdditionalWidgetEvents_EmptySelection(UCoverageWidgetAdditionalEventHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers setup: required Harness is null");
	}
	Harness.HandleSelectionChanged("", ESelectInfo::OnMouseClick);
	return Harness.ComboSelectionChangedCount == 1
		&& Harness.LastSelectedItem.Len() == 0
		&& Harness.LastSelectionType == int(ESelectInfo::OnMouseClick);
}
