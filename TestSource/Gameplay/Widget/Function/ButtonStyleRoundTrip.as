/**
 * UButton WidgetStyle and SetStyle round-trip of an FButtonStyle. C++ executes
 * ButtonStyleRoundTrip and expects 1, so that name is part of the contract and
 * is kept verbatim. The observers cover a copied style that does not write back
 * into the original; a missed MakeWidget returns 0.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.ButtonStyleRoundTrip
 * @Harness Function
 * @Tag Gameplay.Widget.ButtonStyleRoundTrip
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive UButton FButtonStyle WidgetStyle / SetStyle.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::ButtonStyleRoundTrip
 * @Provenance Oracle ExecuteAndExpectInt ButtonStyleRoundTrip == 1.
 * @Provenance Extra: MakeWidget miss returns 0; CopiedStyle is independent of the first Style.
 * @Provenance DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Write a button style through WidgetStyle and then through SetStyle.
	 *
	 * @Kind Observe
	 * @Covers Widget.ButtonStyleRoundTrip
	 * @Inputs a button from MakeWidget
	 * @Return 1 after both writes; 0 on a missed MakeWidget
	 */
	UFUNCTION()
	int ButtonStyleRoundTrip()
	{
		UButton Button = Cast<UButton>(MakeWidget(UButton::StaticClass(), n"ButtonStyleProbe"));
		if (Button == null)
		{
			return 0;
		}

		FButtonStyle Style = Button.WidgetStyle;
		Style.Normal = FSlateBrush(FLinearColor(0.10f, 0.20f, 0.30f, 1.0f));
		Style.Hovered = FSlateBrush(FLinearColor(0.20f, 0.30f, 0.40f, 1.0f));
		Style.Pressed = FSlateBrush(FLinearColor(0.30f, 0.40f, 0.50f, 1.0f));
		Style.Disabled = FSlateBrush(FLinearColor(0.40f, 0.50f, 0.60f, 1.0f));
		Style.NormalPadding = FMargin(1.0f, 2.0f, 3.0f, 4.0f);
		Style.PressedPadding = FMargin(5.0f, 6.0f, 7.0f, 8.0f);
		Button.WidgetStyle = Style;

		FButtonStyle CopiedStyle = Button.WidgetStyle;
		CopiedStyle.Normal = FSlateBrush(FLinearColor(0.55f, 0.65f, 0.75f, 1.0f));
		CopiedStyle.PressedPadding = FMargin(9.0f, 10.0f, 11.0f, 12.0f);
		Button.SetStyle(CopiedStyle);
		return 1;
	}

	/**
	 * Observe that mutating a copied FButtonStyle leaves the original padding alone.
	 *
	 * @Kind Observe
	 * @Covers Widget.ButtonStyleRoundTrip
	 * @Inputs a style and a mutated copy of it
	 * @Return true when the original horizontal total stays 4 and the copy reads 20
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopiedStyleIndependence()
	{
		FButtonStyle Style;
		Style.NormalPadding = FMargin(1.0f, 2.0f, 3.0f, 4.0f);
		FButtonStyle CopiedStyle = Style;
		CopiedStyle.NormalPadding = FMargin(9.0f, 10.0f, 11.0f, 12.0f);

		if (Style.NormalPadding.GetTotalSpaceAlongHorizontal() != 4.0f)
		{
			return false;
		}
		return CopiedStyle.NormalPadding.GetTotalSpaceAlongHorizontal() == 20.0f;
	}
}
