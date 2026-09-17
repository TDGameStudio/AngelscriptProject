/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Baseline
 */
// Optional font/outline C++ tokens stay omitted (empty substitution); only always-present fields.
// Oracle: SetFontFromStruct()==1 after Size 31, Typeface Bold, outline size 2, copy-then-SetFont.
// Extra: default Font.Size is 0; mutating a copy does not change the source Size until assigned.
// DefaultSafe. Widget is created by MakeWidget.

int SetFontFromStruct()
{
	UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"FontInfoProbe"));
	if (Text == null)
	{
		return 0;
	}

	FSlateFontInfo Font;
	Font.Size = 31.0f;
	Font.TypefaceFontName = n"Bold";
	Font.OutlineSettings.OutlineSize = 2;
	Font.OutlineSettings.OutlineColor = FLinearColor(0.2f, 0.4f, 0.6f, 0.8f);

	if (Font.FontObject != null || Font.FontMaterial != null)
	{
		return 5;
	}
	if (Font.Size != 31.0f)
	{
		return 10;
	}
	if (Font.TypefaceFontName != n"Bold")
	{
		return 20;
	}
	if (Font.OutlineSettings.OutlineSize != 2
		|| Font.OutlineSettings.OutlineMaterial != null)
	{
		return 45;
	}
	if (Font.OutlineSettings.OutlineColor.R != 0.2f
		|| Font.OutlineSettings.OutlineColor.G != 0.4f
		|| Font.OutlineSettings.OutlineColor.B != 0.6f
		|| Font.OutlineSettings.OutlineColor.A != 0.8f)
	{
		return 46;
	}

	Font.Size += 1.0f;
	Font.OutlineSettings.OutlineSize += 1;
	FSlateFontInfo CopiedFont = Font;
	Text.SetFont(CopiedFont);
	return 1;
}

int Observe_SetFontFromStruct_Nominal()
{
	return SetFontFromStruct();
}

float Observe_SlateFontInfo_DefaultSize()
{
	FSlateFontInfo Font;
	return Font.Size;
}

bool Observe_SlateFontInfo_CopyIndependence()
{
	FSlateFontInfo Font;
	Font.Size = 31.0f;
	FSlateFontInfo CopiedFont = Font;
	CopiedFont.Size += 1.0f;
	return Font.Size == 31.0f && CopiedFont.Size == 32.0f;
}
/** @end */
