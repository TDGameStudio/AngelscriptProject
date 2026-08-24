// Theme: Gameplay.Widget. Positive UTextBlock SetText/GetText/SetColorAndOpacity.
// C++: AngelscriptCoverageWidgetTests.cpp::TextBlockTextAndColorRoundTrip
// Oracle ExecuteAndExpectInt TextBlockTextAndColor == 1.
// Extra: MakeWidget miss returns 0. DefaultSafe.

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

bool Observe_TextBlockTextAndColor_Nominal()
{
	return TextBlockTextAndColor() == 1;
}
