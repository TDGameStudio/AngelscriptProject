/**
 * @version v1
 * @summary UTextBlock SetText, GetText and SetColorAndOpacity. C++ executes TextBlockTextAndColor and expects 1, so that name is part of the contract and is kept verbatim. A missed MakeWidget returns 0.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary UTextBlock SetText, GetText and SetColorAndOpacity. C++ executes TextBlockTextAndColor and expects 1, so that name is part of the contract and is kept verbatim. A missed MakeWidget returns 0.
 * @topic Baseline
 */
namespace WidgetTest
{
	/**
	 * Write text twice and then a color onto a text block.
	 *
	 * @Kind Observe
	 * @Covers Widget.TextBlockTextAndColorRoundTrip
	 * @Inputs a text block from MakeWidget
	 * @Return 1 when both GetText reads match; 0 on a missed MakeWidget; 10 or 20 on a text mismatch
	 */
	UFUNCTION()
	int TextBlockTextAndColor()
	{
		UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"FocusedTextProbe"));
		if (Text == null)
		{
			return 0;
		}

		Text.SetText(FText::FromString("Coverage Text"));
		if (Text.GetText().ToString() != "Coverage Text")
		{
			return 10;
		}

		Text.SetText(FText::FromString("Updated Coverage Text"));
		if (Text.GetText().ToString() != "Updated Coverage Text")
		{
			return 20;
		}

		Text.SetColorAndOpacity(FSlateColor(FLinearColor(0.125f, 0.375f, 0.625f, 1.0f)));
		return 1;
	}
}
/** @end */
