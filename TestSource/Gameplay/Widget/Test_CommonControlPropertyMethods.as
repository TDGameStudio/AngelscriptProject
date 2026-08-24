// Theme: Gameplay.Widget. Positive common control property methods.
// C++: AngelscriptCoverageWidgetTests.cpp::CommonControlPropertyMethods
// Oracle ExecuteBatchAndExpectInt each helper == 1:
// TextBlockControl, EditableTextControl, ProgressBarControl, SliderControl,
// CheckBoxControl, ImageControl, ButtonControl.
// Extra: Slider GetValue 1.5; CheckBox true/false; Button disabled; null MakeWidget 0.
// DefaultSafe.

int TextBlockControl()
{
	UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"TextProbe"));
	if (Text == null)
	{
		return 0;
	}

	Text.SetText(FText::FromString("Score 42"));
	FText CurrentText = Text.GetText();
	Text.SetColorAndOpacity(FSlateColor(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f)));
	FSlateFontInfo Font;
	Text.SetFont(Font);
	Text.SetFontSize(24);
	Text.SetMinDesiredWidth(128.0f);
	Text.SetJustification(ETextJustify::Center);
	return 1;
}

int EditableTextControl()
{
	UEditableText Editable = Cast<UEditableText>(MakeWidget(UEditableText::StaticClass(), n"EditableProbe"));
	if (Editable == null)
	{
		return 0;
	}

	Editable.SetText(FText::FromString("Player"));
	Editable.SetHintText(FText::FromString("Name"));
	Editable.SetIsReadOnly(true);
	Editable.SetJustification(ETextJustify::Right);
	FText CurrentText = Editable.GetText();
	return 1;
}

int ProgressBarControl()
{
	UProgressBar Bar = Cast<UProgressBar>(MakeWidget(UProgressBar::StaticClass(), n"ProgressProbe"));
	if (Bar == null)
	{
		return 0;
	}

	Bar.SetPercent(0.75f);
	Bar.SetFillColorAndOpacity(FLinearColor(0.1f, 0.2f, 0.3f, 1.0f));
	return 1;
}

int SliderControl()
{
	USlider Slider = Cast<USlider>(MakeWidget(USlider::StaticClass(), n"SliderProbe"));
	if (Slider == null)
	{
		return 0;
	}

	Slider.SetMinValue(-2.0f);
	Slider.SetMaxValue(2.0f);
	Slider.SetStepSize(0.25f);
	Slider.SetValue(1.5f);
	return Slider.GetValue() == 1.5f ? 1 : 10;
}

int CheckBoxControl()
{
	UCheckBox CheckBox = Cast<UCheckBox>(MakeWidget(UCheckBox::StaticClass(), n"CheckBoxProbe"));
	if (CheckBox == null)
	{
		return 0;
	}

	CheckBox.SetIsChecked(true);
	if (!CheckBox.IsChecked())
	{
		return 10;
	}

	CheckBox.SetCheckedState(ECheckBoxState::Unchecked);
	if (CheckBox.IsChecked())
	{
		return 20;
	}

	CheckBox.SetIsChecked(true);
	return CheckBox.IsChecked() ? 1 : 30;
}

int ImageControl()
{
	UImage Image = Cast<UImage>(MakeWidget(UImage::StaticClass(), n"ImageProbe"));
	if (Image == null)
	{
		return 0;
	}

	UTexture2D Texture = nullptr;
	UMaterialInterface Material = nullptr;
	Image.SetBrushFromTexture(Texture, false);
	Image.SetBrushFromMaterial(Material);
	Image.SetColorAndOpacity(FLinearColor(0.2f, 0.3f, 0.4f, 1.0f));
	Image.SetBrushTintColor(FSlateColor(FLinearColor(0.4f, 0.6f, 0.8f, 1.0f)));
	Image.SetDesiredSizeOverride(FVector2D(64.0f, 32.0f));
	return 1;
}

int ButtonControl()
{
	UButton Button = Cast<UButton>(MakeWidget(UButton::StaticClass(), n"ButtonProbe"));
	if (Button == null)
	{
		return 0;
	}

	Button.SetIsEnabled(false);
	Button.SetColorAndOpacity(FLinearColor(0.3f, 0.2f, 0.1f, 1.0f));
	Button.SetBackgroundColor(FLinearColor(0.8f, 0.7f, 0.6f, 1.0f));
	return !Button.GetIsEnabled() ? 1 : 10;
}

bool Observe_TextBlockControl_Nominal()
{
	return TextBlockControl() == 1;
}

bool Observe_EditableTextControl_Nominal()
{
	return EditableTextControl() == 1;
}

bool Observe_ProgressBarControl_Nominal()
{
	return ProgressBarControl() == 1;
}

bool Observe_SliderControl_Nominal()
{
	return SliderControl() == 1;
}

bool Observe_CheckBoxControl_Nominal()
{
	return CheckBoxControl() == 1;
}

bool Observe_ImageControl_NullResources()
{
	return ImageControl() == 1;
}

bool Observe_ButtonControl_Disabled()
{
	return ButtonControl() == 1;
}
