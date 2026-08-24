// Theme: Gameplay.Widget. Positive UBorder setters and FMargin totals.
// C++: AngelscriptCoverageWidgetTests.cpp::BorderAndMarginStateRoundTrips
// Oracle ExecuteAndExpectInt BorderAndMarginOperations == 1.
// Extra: default FMargin totals 0; MakeWidget miss returns 0. DefaultSafe.

int BorderAndMarginOperations()
{
	UBorder Border = Cast<UBorder>(MakeWidget(UBorder::StaticClass(), n"BorderProbe"));
	UTextBlock Content = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"BorderContentProbe"));
	if (Border == null || Content == null)
	{
		return 0;
	}

	FMargin Padding = FMargin(4.0f, 5.0f, 6.0f, 7.0f);
	if (Padding.GetTotalSpaceAlongHorizontal() != 10.0f
		|| Padding.GetTotalSpaceAlongVertical() != 12.0f)
	{
		return 10;
	}

	FSlateBrush Brush = FSlateBrush(FLinearColor(0.05f, 0.15f, 0.25f, 1.0f));
	Brush.DrawAs = ESlateBrushDrawType::Border;
	Brush.Margin = Padding;
	Brush.TintColor = FSlateColor(FLinearColor(0.35f, 0.45f, 0.55f, 1.0f));
	Border.SetBrush(Brush);
	Border.SetBrushColor(FLinearColor(0.65f, 0.55f, 0.45f, 1.0f));
	Border.SetContentColorAndOpacity(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
	Border.SetPadding(Padding);
	Border.SetHorizontalAlignment(EHorizontalAlignment::HAlign_Center);
	Border.SetVerticalAlignment(EVerticalAlignment::VAlign_Bottom);
	return Border.SetContent(Content) != null && Content.GetParent() == Border ? 1 : 20;
}

bool Observe_BorderAndMarginOperations_Nominal()
{
	return BorderAndMarginOperations() == 1;
}

bool Observe_DefaultMargin_EmptyTotals()
{
	FMargin Padding;
	return Padding.GetTotalSpaceAlongHorizontal() == 0.0f
		&& Padding.GetTotalSpaceAlongVertical() == 0.0f;
}
