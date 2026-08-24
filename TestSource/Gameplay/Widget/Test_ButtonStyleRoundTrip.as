// Theme: Gameplay.Widget. Positive UButton FButtonStyle WidgetStyle / SetStyle.
// C++: AngelscriptCoverageWidgetTests.cpp::ButtonStyleRoundTrip
// Oracle ExecuteAndExpectInt ButtonStyleRoundTrip == 1.
// Extra: MakeWidget miss returns 0; CopiedStyle is independent of the first Style.
// DefaultSafe.

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

bool Observe_ButtonStyleRoundTrip_Nominal()
{
	return ButtonStyleRoundTrip() == 1;
}
