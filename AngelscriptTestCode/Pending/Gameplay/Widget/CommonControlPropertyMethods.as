/**
 * @version v1
 * @summary Common control property methods for text, editable text, progress, slider, checkbox, image and button. C++ executes each helper and expects 1, so those names are part of the contract and are kept verbatim. Slider.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Common control property methods for text, editable text, progress, slider, checkbox, image and button. C++ executes each helper and expects 1, so those names are part of the contract and are kept verbatim. Slider.
 * @topic Baseline
 */
namespace WidgetTest
{
	/**
	 * Write text, color, font, width and justification onto a text block.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs a text block from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 */
	UFUNCTION()
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

	/**
	 * Write text, hint, read-only and justification onto an editable text.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs an editable text from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 */
	UFUNCTION()
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

	/**
	 * Write percent and fill color onto a progress bar.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs a progress bar from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 */
	UFUNCTION()
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

	/**
	 * Write range, step and value onto a slider and read 1.5 back.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs a slider from MakeWidget
	 * @Return 1 when GetValue is 1.5; 0 on a missed MakeWidget; 10 on a value mismatch
	 */
	UFUNCTION()
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

	/**
	 * Check, uncheck and re-check a checkbox.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs a checkbox from MakeWidget
	 * @Return 1 when the last IsChecked is true; 0 on a missed MakeWidget; 10/20/30 on state mismatch
	 */
	UFUNCTION()
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

	/**
	 * Write null texture and material brushes plus color, tint and size onto an image.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs an image from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 * @Boundary null texture and material
	 */
	UFUNCTION()
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

	/**
	 * Disable a button and write its colors.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs a button from MakeWidget
	 * @Return 1 when GetIsEnabled is false; 0 on a missed MakeWidget; 10 when it stays enabled
	 * @Boundary disabled
	 */
	UFUNCTION()
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

	/**
	 * Observe that the null-resource image path returns 1.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs none
	 * @Return true when ImageControl returns 1
	 * @Boundary null resources
	 */
	UFUNCTION()
	bool ImageControlNullResources()
	{
		return ImageControl() == 1;
	}

	/**
	 * Observe that the disabled button path returns 1.
	 *
	 * @Kind Observe
	 * @Covers Widget.CommonControlPropertyMethods
	 * @Inputs none
	 * @Return true when ButtonControl returns 1
	 * @Boundary disabled
	 */
	UFUNCTION()
	bool ButtonControlDisabled()
	{
		return ButtonControl() == 1;
	}
}
/** @end */
