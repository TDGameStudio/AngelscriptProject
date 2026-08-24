// Theme: Gameplay.Widget. Positive UOverlay multi-child layer order.
// C++: AngelscriptCoverageWidgetTests.cpp::OverlayLayerOrderOperations
// Oracle ExecuteAndExpectInt OverlayLayerOrderOperations == 1.
// Extra: MakeWidget miss returns 0. DefaultSafe.

int OverlayLayerOrderOperations()
{
	UOverlay Overlay = Cast<UOverlay>(MakeWidget(UOverlay::StaticClass(), n"LayeredOverlayProbe"));
	UTextBlock Back = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"OverlayBackLayer"));
	UTextBlock Middle = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"OverlayMiddleLayer"));
	UTextBlock Front = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"OverlayFrontLayer"));
	if (Overlay == null || Back == null || Middle == null || Front == null)
	{
		return 0;
	}

	UOverlaySlot BackSlot = Overlay.AddChildToOverlay(Back);
	UOverlaySlot MiddleSlot = Overlay.AddChildToOverlay(Middle);
	UOverlaySlot FrontSlot = Overlay.AddChildToOverlay(Front);
	if (BackSlot == null || MiddleSlot == null || FrontSlot == null)
	{
		return 10;
	}
	if (Overlay.GetChildrenCount() != 3)
	{
		return 20;
	}
	if (Overlay.GetChildAt(0) != Back || Overlay.GetChildAt(1) != Middle || Overlay.GetChildAt(2) != Front)
	{
		return 30;
	}

	BackSlot.SetPadding(FMargin(1.0f, 2.0f, 3.0f, 4.0f));
	MiddleSlot.SetHorizontalAlignment(EHorizontalAlignment::HAlign_Center);
	FrontSlot.SetVerticalAlignment(EVerticalAlignment::VAlign_Bottom);
	return 1;
}

bool Observe_OverlayLayerOrderOperations_Nominal()
{
	return OverlayLayerOrderOperations() == 1;
}
