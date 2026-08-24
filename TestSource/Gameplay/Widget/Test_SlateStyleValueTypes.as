// Theme: Gameplay.Widget. Positive FSlateColor / FSlateBrush constructors.
// C++: AngelscriptCoverageWidgetTests.cpp::SlateStyleValueTypes
// Oracle ExecuteAndExpectInt SlateColorAndBrushConstructors == 1.
// Extra: MakeWidget miss returns 0. DefaultSafe.

int SlateColorAndBrushConstructors()
{
	FSlateColor LinearColor = FSlateColor(FLinearColor(0.2f, 0.4f, 0.6f, 1.0f));
	FSlateColor TableColor = FSlateColor(EStyleColor::Foreground);
	FSlateBrush ColorBrush = FSlateBrush(FLinearColor(0.9f, 0.1f, 0.2f, 1.0f));
	FSlateBrush StyleBrush = FSlateBrush(n"WhiteBrush");

	UImage Image = Cast<UImage>(MakeWidget(UImage::StaticClass(), n"SlateStyleImageProbe"));
	UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"SlateStyleTextProbe"));
	if (Image == null || Text == null)
	{
		return 0;
	}

	Image.SetBrush(ColorBrush);
	Image.SetBrushTintColor(LinearColor);
	Text.SetColorAndOpacity(TableColor);
	Text.SetFontSize(18);
	return 1;
}

bool Observe_SlateColorAndBrushConstructors_Nominal()
{
	return SlateColorAndBrushConstructors() == 1;
}
