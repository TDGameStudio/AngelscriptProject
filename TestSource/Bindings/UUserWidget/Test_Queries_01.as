// Purpose: Observe user-widget palette/root/tree queries and FPaintContext
// allotted geometry plus style color/brush/font lookups.
// Runner owns the user-widget fixture.
// AS-facing API: FText UUserWidget.GetPaletteCategory() const;
// UWidget UUserWidget.GetRootWidget() const;
// void UUserWidget.GetAllWidgets(TArray<UWidget>& Widgets) const;
// const FGeometry& FPaintContext.GetAllottedGeometry() const;
// FLinearColor FPaintContext.GetStyleColor(const FName& Color) const;
// const FSlateBrush& FPaintContext.GetStyleBrush(const FName& Brush) const;
// FSlateFontInfo FPaintContext.GetStyleFont(int32 Size) const;
// Inputs: Runner-owned UUserWidget, ConstructWidget+SetRootWidget, an out
// TArray for GetAllWidgets, a default FPaintContext, n"DefaultForeground" /
// n"WhiteBrush", missing n"TestSource.Missing", font sizes 12 and 0.
// Expected observations: Empty GetRootWidget is null. After SetRootWidget the
// root identity matches the constructed child. GetAllWidgets keeps the
// sentinel at index 0. Allotted geometry local size is non-negative.
// Style color alpha is in 0..1. Font sizes 12 and 0 round-trip.
// Boundary/ownership: GetAllottedGeometry and GetStyleBrush return aliases into
// paint/style data. GetAllWidgets writes into the caller array. SetupOwner=Runner.

UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

namespace TS_UUserWidget_Queries_01
{
	bool Observe_GetPaletteCategory_Nominal(UUserWidget Widget, const FString& Expected)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_Queries_01 setup: required Widget is null");
		}
		return Widget.GetPaletteCategory().ToString() == Expected;
	}

	bool Observe_GetRootWidget_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_Queries_01 setup: required Widget is null");
		}
		UWidget EmptyRoot = Widget.GetRootWidget();
		UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.QueryRoot");
		if (Child is null)
		{
			throw("TS_UUserWidget_Queries_01 setup: ConstructWidget returned null");
		}
		Widget.SetRootWidget(Child);
		UWidget Root = Widget.GetRootWidget();
		Widget.SetRootWidget(nullptr);
		UWidget ClearedRoot = Widget.GetRootWidget();
		return EmptyRoot is null && Root == Child && ClearedRoot is null;
	}

	bool Observe_GetAllWidgets_Nominal(UUserWidget Widget, UWidget Sentinel)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_Queries_01 setup: required Widget is null");
		}
		TArray<UWidget> EmptyWidgets;
		EmptyWidgets.Add(Sentinel);
		int32 EmptyBefore = EmptyWidgets.Num();
		Widget.GetAllWidgets(EmptyWidgets);
		UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.QueryChild");
		if (Child is null)
		{
			throw("TS_UUserWidget_Queries_01 setup: ConstructWidget returned null");
		}
		Widget.SetRootWidget(Child);
		TArray<UWidget> Widgets;
		Widgets.Add(Sentinel);
		int32 Before = Widgets.Num();
		Widget.GetAllWidgets(Widgets);
		return EmptyWidgets.Num() >= EmptyBefore && EmptyWidgets[0] == Sentinel && Widgets.Num() >= Before && Widgets[0] == Sentinel;
	}

	bool Observe_GetAllottedGeometry_Nominal()
	{
		FPaintContext PaintContext;
		const FGeometry& Allotted = PaintContext.GetAllottedGeometry();
		FVector2D Local = Allotted.GetLocalSize();
		FVector2D Absolute = Allotted.GetAbsoluteSize();
		const FGeometry& Alias = PaintContext.GetAllottedGeometry();
		FVector2D AliasLocal = Alias.GetLocalSize();
		return Local.X >= 0.0 && Local.Y >= 0.0 && Absolute.X >= 0.0 && AliasLocal.X == Local.X;
	}

	bool Observe_GetStyleColor_Nominal()
	{
		FPaintContext PaintContext;
		FLinearColor Foreground = PaintContext.GetStyleColor(n"DefaultForeground");
		FLinearColor Missing = PaintContext.GetStyleColor(n"TestSource.MissingColor");
		FLinearColor Empty = PaintContext.GetStyleColor(NAME_None);
		return Foreground.A >= 0.0 && Foreground.A <= 1.0 && Missing.A >= 0.0 && Missing.A <= 1.0 && Empty.A >= 0.0 && Empty.A <= 1.0;
	}

	bool Observe_GetStyleBrush_Nominal()
	{
		FPaintContext PaintContext;
		const FSlateBrush& White = PaintContext.GetStyleBrush(n"WhiteBrush");
		const FSlateBrush& Missing = PaintContext.GetStyleBrush(n"TestSource.MissingBrush");
		const FSlateBrush& Alias = PaintContext.GetStyleBrush(n"WhiteBrush");
		return White.ImageSize.X >= 0.0 && Missing.ImageSize.X >= 0.0 && Alias.ImageSize.X == White.ImageSize.X;
	}

	bool Observe_GetStyleFont_Nominal()
	{
		FPaintContext PaintContext;
		FSlateFontInfo Nominal = PaintContext.GetStyleFont(12);
		FSlateFontInfo EmptySize = PaintContext.GetStyleFont(0);
		return Nominal.Size == 12 && EmptySize.Size == 0;
	}
}
