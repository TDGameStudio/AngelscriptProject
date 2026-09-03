/**
 * UOverlay multi-child layer order plus slot padding and alignment. C++ executes
 * OverlayLayerOrderOperations and expects 1, so that name is part of the contract
 * and is kept verbatim. A missed MakeWidget returns 0.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.OverlayLayerOrderOperations
 * @Harness Function
 * @Tag Gameplay.Widget.OverlayLayerOrderOperations
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive UOverlay multi-child layer order.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::OverlayLayerOrderOperations
 * @Provenance Oracle ExecuteAndExpectInt OverlayLayerOrderOperations == 1.
 * @Provenance Extra: MakeWidget miss returns 0. DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Add back, middle and front overlay children and configure each slot.
	 *
	 * @Kind Observe
	 * @Covers Widget.OverlayLayerOrderOperations
	 * @Inputs an overlay and three text children from MakeWidget
	 * @Return 1 when the child order is back/middle/front; 0 on a missed MakeWidget; 10/20/30 on order mismatch
	 */
	UFUNCTION()
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
}
