/**
 * Canvas, vertical-box, horizontal-box, overlay, scroll-box and size-box layout
 * operations. C++ executes each helper and expects 1, so those names are part of
 * the contract and are kept verbatim. A missed MakeWidget returns 0.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.ContainerLayoutOperations
 * @Harness Function
 * @Tag Gameplay.Widget.ContainerLayoutOperations
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive canvas / box / overlay / scroll layout ops.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::ContainerLayoutOperations
 * @Provenance Oracle ExecuteBatchAndExpectInt each helper == 1:
 * @Provenance CanvasSlotOperations, BoxChildOperations, HorizontalOverlayAndScrollOperations.
 * @Provenance Extra: MakeWidget miss returns 0. DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Add a canvas child and write position, size and anchors.
	 *
	 * @Kind Observe
	 * @Covers Widget.ContainerLayoutOperations
	 * @Inputs a canvas and a text child from MakeWidget
	 * @Return 1 after the slot writes; 0 on a missed MakeWidget; 10 when the slot or parent misses
	 */
	UFUNCTION()
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

	/**
	 * Add, reorder-remove and clear children on a vertical box.
	 *
	 * @Kind Observe
	 * @Covers Widget.ContainerLayoutOperations
	 * @Inputs a vertical box and two text children from MakeWidget
	 * @Return 1 when ClearChildren leaves no children; 0 on a missed MakeWidget; 10/20/30/40/50/60 on mismatch
	 */
	UFUNCTION()
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

	/**
	 * Parent horizontal and overlay children, then exercise scroll and size-box setters.
	 *
	 * @Kind Observe
	 * @Covers Widget.ContainerLayoutOperations
	 * @Inputs a horizontal box, overlay, scroll box, size box and two text children from MakeWidget
	 * @Return 1 after the layout writes; 0 on a missed MakeWidget; 10/20/30 on parent mismatch
	 */
	UFUNCTION()
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
}
