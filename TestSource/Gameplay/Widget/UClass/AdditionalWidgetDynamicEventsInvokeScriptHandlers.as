/**
 * A harness whose Bind attaches commit, slider and combo handlers that C++ then
 * broadcasts. C++ compiles the class and looks up Bind plus the UPROPERTY names,
 * so those names are part of the contract and are kept verbatim. The observers
 * cover the empty default, the C++ broadcast values, an empty selected item and
 * the independence of two instances.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
 * @Harness UClass
 * @Tag Gameplay.Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
 * @Provenance Theme: Gameplay.Widget. Positive additional dynamic events (commit / slider / combo).
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::AdditionalWidgetDynamicEventsInvokeScriptHandlers
 * @Provenance Oracle after Bind + Broadcast: TextCommittedCount 1, LastCommittedText "Committed",
 * @Provenance LastCommitMethod int(ETextCommit::OnEnter), SliderChangedCount 1, LastSliderValue 0.625,
 * @Provenance ComboSelectionChangedCount 1, LastSelectedItem "High",
 * @Provenance LastSelectionType int(ESelectInfo::OnMouseClick).
 * @Provenance Extra: defaults 0 / empty / -1; empty selected item. DefaultSafe.
 */

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

	/**
	 * Bind commit, slider and combo events onto this harness.
	 *
	 * @Kind Action
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs an editable text, a slider and a combo box
	 * @Return none; AddUFunction on OnTextCommitted, OnValueChanged and OnSelectionChanged
	 * @Param Editable the editable text
	 * @Param Slider the slider
	 * @Param Combo the combo box
	 */
	UFUNCTION()
	void Bind(UEditableText Editable, USlider Slider, UComboBoxString Combo)
	{
		Editable.OnTextCommitted.AddUFunction(this, n"HandleTextCommitted");
		Slider.OnValueChanged.AddUFunction(this, n"HandleSliderValueChanged");
		Combo.OnSelectionChanged.AddUFunction(this, n"HandleSelectionChanged");
	}

	/**
	 * Record a committed text event.
	 *
	 * @Kind Action
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the committed text and the commit method
	 * @Return TextCommittedCount incremented, LastCommittedText and LastCommitMethod updated
	 * @Param Text the committed text
	 * @Param CommitMethod the commit method
	 */
	UFUNCTION()
	void HandleTextCommitted(const FText&in Text, ETextCommit CommitMethod)
	{
		TextCommittedCount += 1;
		LastCommittedText = Text.ToString();
		LastCommitMethod = int(CommitMethod);
	}

	/**
	 * Record a slider value-changed event.
	 *
	 * @Kind Action
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the new slider value
	 * @Return SliderChangedCount incremented and LastSliderValue updated
	 * @Param Value the new slider value
	 */
	UFUNCTION()
	void HandleSliderValueChanged(float32 Value)
	{
		SliderChangedCount += 1;
		LastSliderValue = Value;
	}

	/**
	 * Record a combo selection-changed event.
	 *
	 * @Kind Action
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the selected item and the selection type
	 * @Return ComboSelectionChangedCount incremented, LastSelectedItem and LastSelectionType updated
	 * @Param SelectedItem the selected option
	 * @Param SelectionType how the option was chosen
	 */
	UFUNCTION()
	void HandleSelectionChanged(FString SelectedItem, ESelectInfo SelectionType)
	{
		ComboSelectionChangedCount += 1;
		LastSelectedItem = SelectedItem;
		LastSelectionType = int(SelectionType);
	}

	/**
	 * Observe that an untouched harness has no events and sentinel defaults.
	 *
	 * @Kind Observe
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs none
	 * @Return true when all counts are 0, strings are empty, methods are -1 and the slider is 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TextCommittedCount != 0)
		{
			return false;
		}
		if (SliderChangedCount != 0)
		{
			return false;
		}
		if (ComboSelectionChangedCount != 0)
		{
			return false;
		}
		if (LastCommittedText.Len() != 0)
		{
			return false;
		}
		if (LastCommitMethod != -1)
		{
			return false;
		}
		if (LastSliderValue != 0.0f)
		{
			return false;
		}
		if (LastSelectedItem.Len() != 0)
		{
			return false;
		}
		return LastSelectionType == -1;
	}

	/**
	 * Observe that the C++ broadcast values land on this harness.
	 *
	 * @Kind Observe
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs the committed text, slider value and combo selection C++ broadcasts
	 * @Return true when every count is 1 and the last values match the broadcast
	 */
	UFUNCTION()
	bool BroadcastValues()
	{
		HandleTextCommitted(FText::FromString("Committed"), ETextCommit::OnEnter);
		HandleSliderValueChanged(0.625f);
		HandleSelectionChanged("High", ESelectInfo::OnMouseClick);

		if (TextCommittedCount != 1)
		{
			return false;
		}
		if (LastCommittedText != "Committed")
		{
			return false;
		}
		if (LastCommitMethod != int(ETextCommit::OnEnter))
		{
			return false;
		}
		if (SliderChangedCount != 1)
		{
			return false;
		}
		if (LastSliderValue != 0.625f)
		{
			return false;
		}
		if (ComboSelectionChangedCount != 1)
		{
			return false;
		}
		if (LastSelectedItem != "High")
		{
			return false;
		}
		return LastSelectionType == int(ESelectInfo::OnMouseClick);
	}

	/**
	 * Observe that an empty selected item is stored as an empty string.
	 *
	 * @Kind Observe
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs an empty combo selection
	 * @Return true when the count is 1 and the last item is empty
	 * @Boundary empty selected item
	 */
	UFUNCTION()
	bool EmptySelection()
	{
		HandleSelectionChanged("", ESelectInfo::OnMouseClick);

		if (ComboSelectionChangedCount != 1)
		{
			return false;
		}
		if (LastSelectedItem.Len() != 0)
		{
			return false;
		}
		return LastSelectionType == int(ESelectInfo::OnMouseClick);
	}

	/**
	 * Observe that writing this harness leaves another harness at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Widget.AdditionalWidgetDynamicEventsInvokeScriptHandlers
	 * @Inputs a second harness
	 * @Return true when this records the commit and the other still reads 0 / -1
	 * @Param Second the other harness, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageWidgetAdditionalEventHarness Second)
	{
		if (Second is null)
		{
			throw("AdditionalWidgetDynamicEventsInvokeScriptHandlers setup: required Second is null");
		}
		HandleTextCommitted(FText::FromString("Committed"), ETextCommit::OnEnter);

		if (TextCommittedCount != 1)
		{
			return false;
		}
		if (Second.TextCommittedCount != 0)
		{
			return false;
		}
		return Second.LastCommitMethod == -1;
	}
}
