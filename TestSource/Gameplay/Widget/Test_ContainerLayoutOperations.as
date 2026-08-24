// Theme: Gameplay.Widget. Positive canvas / box / overlay / scroll layout ops.
// C++: AngelscriptCoverageWidgetTests.cpp::ContainerLayoutOperations
// Oracle ExecuteBatchAndExpectInt each helper == 1:
// CanvasSlotOperations, BoxChildOperations, HorizontalOverlayAndScrollOperations.
// Extra: MakeWidget miss returns 0. DefaultSafe.

int CanvasSlotOperations()
{
	UCanvasPanel Canvas = Cast<UCanvasPanel>(MakeWidget(UCanvasPanel::StaticClass(), n"CanvasProbe"));
	UTextBlock Child = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"CanvasChild"));
	if (Canvas == null || Child == null)
	{
		return 0;
	}

	UCanvasPanelSlot Slot = Canvas.AddChildToCanvas(Child);
	if (Slot == null || Child.GetParent() != Canvas)
	{
		return 10;
	}

	Slot.SetPosition(FVector2D(12.0f, 34.0f));
	Slot.SetSize(FVector2D(56.0f, 78.0f));
	Slot.SetAnchors(FAnchors(0.0f, 0.0f, 1.0f, 1.0f));
	return 1;
}

int BoxChildOperations()
{
	UVerticalBox Vertical = Cast<UVerticalBox>(MakeWidget(UVerticalBox::StaticClass(), n"VerticalProbe"));
	UTextBlock First = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"VerticalFirst"));
	UTextBlock Second = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"VerticalSecond"));
	if (Vertical == null || First == null || Second == null)
	{
		return 0;
	}

	if (Vertical.AddChildToVerticalBox(First) == null || Vertical.AddChildToVerticalBox(Second) == null)
	{
		return 10;
	}
	if (First.GetParent() != Vertical || Second.GetParent() != Vertical)
	{
		return 20;
	}
	if (Vertical.GetChildAt(0) != First || Vertical.GetChildAt(1) != Second)
	{
		return 30;
	}
	if (!Vertical.RemoveChildAt(0))
	{
		return 40;
	}
	if (First.GetParent() != null || Vertical.GetChildAt(0) != Second)
	{
		return 50;
	}

	Vertical.ClearChildren();
	return Second.GetParent() == null && !Vertical.HasAnyChildren() ? 1 : 60;
}

int HorizontalOverlayAndScrollOperations()
{
	UHorizontalBox Horizontal = Cast<UHorizontalBox>(MakeWidget(UHorizontalBox::StaticClass(), n"HorizontalProbe"));
	UOverlay Overlay = Cast<UOverlay>(MakeWidget(UOverlay::StaticClass(), n"OverlayProbe"));
	UScrollBox Scroll = Cast<UScrollBox>(MakeWidget(UScrollBox::StaticClass(), n"ScrollProbe"));
	USizeBox SizeBox = Cast<USizeBox>(MakeWidget(USizeBox::StaticClass(), n"SizeBoxProbe"));
	UTextBlock HorizontalChild = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"HorizontalChild"));
	UTextBlock OverlayChild = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"OverlayChild"));
	if (Horizontal == null || Overlay == null || Scroll == null || SizeBox == null || HorizontalChild == null || OverlayChild == null)
	{
		return 0;
	}

	if (Horizontal.AddChildToHorizontalBox(HorizontalChild) == null || HorizontalChild.GetParent() != Horizontal)
	{
		return 10;
	}
	if (Overlay.AddChildToOverlay(OverlayChild) == null || OverlayChild.GetParent() != Overlay)
	{
		return 20;
	}
	if (Horizontal.GetChildAt(0) != HorizontalChild || Overlay.GetChildAt(0) != OverlayChild)
	{
		return 30;
	}

	Scroll.SetScrollOffset(37.0f);
	Scroll.ScrollToStart();
	Scroll.ScrollToEnd();
	SizeBox.SetWidthOverride(200.0f);
	SizeBox.SetHeightOverride(50.0f);
	SizeBox.SetMinDesiredWidth(100.0f);
	return 1;
}

bool Observe_CanvasSlotOperations_Nominal()
{
	return CanvasSlotOperations() == 1;
}

bool Observe_BoxChildOperations_Nominal()
{
	return BoxChildOperations() == 1;
}

bool Observe_HorizontalOverlayAndScrollOperations_Nominal()
{
	return HorizontalOverlayAndScrollOperations() == 1;
}
