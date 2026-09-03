/**
 * UBorder setters plus FMargin totals. C++ executes BorderAndMarginOperations and
 * expects 1, so that name is part of the contract and is kept verbatim. The
 * observers cover the empty FMargin totals; a missed MakeWidget returns 0.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.BorderAndMarginStateRoundTrips
 * @Harness Function
 * @Tag Gameplay.Widget.BorderAndMarginStateRoundTrips
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive UBorder setters and FMargin totals.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::BorderAndMarginStateRoundTrips
 * @Provenance Oracle ExecuteAndExpectInt BorderAndMarginOperations == 1.
 * @Provenance Extra: default FMargin totals 0; MakeWidget miss returns 0. DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Build a bordered text child and apply padding, brush, color and alignment.
	 *
	 * @Kind Observe
	 * @Covers Widget.BorderAndMarginStateRoundTrips
	 * @Inputs a border and a text child from MakeWidget
	 * @Return 1 when SetContent parents the text; 0 on a missed MakeWidget; 10 on margin totals; 20 on parent mismatch
	 */
	UFUNCTION()
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

	/**
	 * Observe that a default FMargin has zero totals on both axes.
	 *
	 * @Kind Observe
	 * @Covers Widget.BorderAndMarginStateRoundTrips
	 * @Inputs a default-constructed margin
	 * @Return true when both totals are 0
	 * @Boundary default FMargin
	 */
	UFUNCTION()
	bool DefaultMarginEmptyTotals()
	{
		FMargin Padding;

		if (Padding.GetTotalSpaceAlongHorizontal() != 0.0f)
		{
			return false;
		}
		return Padding.GetTotalSpaceAlongVertical() == 0.0f;
	}
}
