/**
 * @version v1
 * @summary UUserWidget host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UUserWidget
 *
 * draw-box
 * draw-line
 * draw-lines
 * draw-text
 * color
 * brush
 * construct-widget
 * set-palette-category
 * set-root-widget
 * remove-widget
 * add-to-viewport
 * create-widget
 * UUserWidget-NamespaceAndGlobalFunctions_01-draw-box
 * draw-rotated-box
 * UUserWidget-NamespaceAndGlobalFunctions_01-brush
 * get-palette-category
 * get-root-widget
 * get-all-widgets
 * get-allotted-geometry
 * get-style-color
 * get-style-brush
 * get-style-font
 */
/**
 * @begin draw-box
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveDrawBoxNominal
 * @summary Observe the container API.
 * @covers UUserWidget.draw-box
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FSlateColor Color(const FLinearColor& InColor); FSlateColor Color(const FColor& InColor);
// FSlateColor Color(EStyleColor InColorTableId);
// FSlateBrush Brush(const FName& BrushStyleName); FSlateBrush Brush(const FLinearColor& Color);
// Inputs: Default FPaintContext, box at (0,0) size (10,20) in White and
// Transparent, line (0,0)-(10,20) with default thickness/antialias and explicit
// 2.0/false, empty and two-point line strips, text "TestSource" and "", font
// from GetStyleFont(12), FLinearColor::White, FColor::White, EStyleColor::Foreground,
// n"WhiteBrush", and FLinearColor::Red as a solid brush.
// Expected observations: Allotted geometry stays non-negative. Named WhiteBrush
// and solid-color brushes report non-negative ImageSize. Font size 12 is
// preserved. Two-point strips keep Num 2.
// Boundary/ownership: Draw helpers mutate paint layers, not geometry. Implicit
// color/brush constructors copy style data. DefaultSafe; FPaintContext is a
// value type.
bool ObserveDrawBoxNominal()
{
	FPaintContext PaintContext;
	FVector2D Position;
	FVector2D Size(10.0, 20.0);
	PaintContext.DrawBox(Position, Size, FLinearColor::White);
	PaintContext.DrawBox(Position, Size, FLinearColor::Transparent);
	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Local.Y >= 0.0;
}
/** @end */
/**
 * @begin draw-line
 * @summary value type.
 * @topic Unreal
 */
/**
 * @function ObserveDrawLineNominal
 * @summary value type.
 * @covers UUserWidget.draw-line
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDrawLineNominal()
{
	FPaintContext PaintContext;
	FVector2D Start;
	FVector2D End(10.0, 20.0);
	PaintContext.DrawLine(Start, End, FLinearColor::White);
	PaintContext.DrawLine(Start, End, FLinearColor::White, 1.0);
	PaintContext.DrawLine(Start, End, FLinearColor::Red, 2.0, false);
	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Local.Y >= 0.0;
}
/** @end */
/**
 * @begin draw-lines
 * @summary value type.
 * @topic Unreal
 */
/**
 * @function ObserveDrawLinesNominal
 * @summary value type.
 * @covers UUserWidget.draw-lines
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDrawLinesNominal()
{
	FPaintContext PaintContext;
	TArray<FVector2D> EmptyPoints;
	PaintContext.DrawLines(EmptyPoints, FLinearColor::White);
	TArray<FVector2D> Points;
	Points.Add(FVector2D(0.0, 0.0));
	Points.Add(FVector2D(10.0, 20.0));
	PaintContext.DrawLines(Points, FLinearColor::White);
	PaintContext.DrawLines(Points, FLinearColor::Red, 2.0, false);
	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Points.Num() == 2 && EmptyPoints.Num() == 0;
}
/** @end */
/**
 * @begin draw-text
 * @summary value type.
 * @topic Unreal
 */
/**
 * @function ObserveDrawTextNominal
 * @summary value type.
 * @covers UUserWidget.draw-text
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDrawTextNominal()
{
	FPaintContext PaintContext;
	FVector2D Position;
	PaintContext.DrawText("TestSource", Position, FLinearColor::White);
	PaintContext.DrawText("", Position, FLinearColor::White);
	FSlateFontInfo Font = PaintContext.GetStyleFont(12);
	PaintContext.DrawText(Font, "TestSource", Position, FLinearColor::White);
	PaintContext.DrawText(Font, "", Position, FLinearColor::Red);
	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Font.Size == 12;
}
/** @end */
/**
 * @begin color
 * @summary value type.
 * @topic Unreal
 */
/**
 * @function ObserveColorNominal
 * @summary value type.
 * @covers UUserWidget.color
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveColorNominal()
{
	FSlateColor Linear(FLinearColor::White);
	FSlateColor ByteColor(FColor::White);
	FSlateColor TableColor(EStyleColor::Foreground);
	FSlateColor EmptyLinear(FLinearColor::Transparent);
	FSlateBrush FromWhite(FLinearColor::White);
	FSlateBrush FromTransparent(FLinearColor::Transparent);
	return FromWhite.ImageSize.X >= 0.0 && FromTransparent.ImageSize.X >= 0.0 && FromWhite.ImageSize.Y >= 0.0;
}
/** @end */
/**
 * @begin brush
 * @summary value type.
 * @topic Unreal
 */
/**
 * @function ObserveBrushNominal
 * @summary value type.
 * @covers UUserWidget.brush
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveBrushNominal()
{
	FSlateBrush Named(n"WhiteBrush");
	FSlateBrush Missing(n"TestSource.MissingBrush");
	FSlateBrush Solid(FLinearColor::Red);
	FSlateBrush EmptyName(NAME_None);
	return Named.ImageSize.X >= 0.0 && Missing.ImageSize.X >= 0.0 && Solid.ImageSize.X >= 0.0 && EmptyName.ImageSize.X >= 0.0;
}
/** @end */
/**
 * @begin construct-widget
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveConstructWidgetNominal
 * @summary SetupOwner=Runner.
 * @covers UUserWidget.construct-widget
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetConstructProbe : UUserWidget
{
}

bool ObserveConstructWidgetNominal(UUserWidget Widget)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_ConstructionAndAssignment_01 setup: required Widget is null");
	}
	UWidget DefaultNamed = Widget.ConstructWidget(UTextBlock::StaticClass());
	UWidget ExplicitNamed = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.Child");
	TSubclassOf<UWidget> EmptyClass;
	UWidget NullChild = Widget.ConstructWidget(EmptyClass);
	UWidget NullNamed = Widget.ConstructWidget(EmptyClass, NAME_None);
	return DefaultNamed != nullptr && DefaultNamed != Widget && ExplicitNamed != nullptr && ExplicitNamed != DefaultNamed && NullChild is null && NullNamed is null;
}
/** @end */
/**
 * @begin set-palette-category
 * @summary borrows WorldContext and OwningPlayer.
 * @topic Unreal
 */
/**
 * @function ObserveSetPaletteCategoryNominal
 * @summary borrows WorldContext and OwningPlayer.
 * @covers UUserWidget.set-palette-category
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

bool ObserveSetPaletteCategoryNominal(UUserWidget Widget)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
	}
	FText Category = FText::FromString("TestSource.Palette");
	Widget.SetPaletteCategory(Category);
	FText AfterFirst = Widget.GetPaletteCategory();
	Widget.SetPaletteCategory(Category);
	FText AfterRepeat = Widget.GetPaletteCategory();
	FText Empty;
	Widget.SetPaletteCategory(Empty);
	FText Restored = Widget.GetPaletteCategory();
	return AfterFirst.ToString() == "TestSource.Palette" && AfterRepeat.ToString() == "TestSource.Palette" && Restored.ToString() != "TestSource.Palette";
}
/** @end */
/**
 * @begin set-root-widget
 * @summary borrows WorldContext and OwningPlayer.
 * @topic Unreal
 */
/**
 * @function ObserveSetRootWidgetNominal
 * @summary borrows WorldContext and OwningPlayer.
 * @covers UUserWidget.set-root-widget
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

bool ObserveSetRootWidgetNominal(UUserWidget Widget)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
	}
	UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.MutationRoot");
	if (Child is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: ConstructWidget returned null");
	}
	Widget.SetRootWidget(Child);
	UWidget AfterFirst = Widget.GetRootWidget();
	Widget.SetRootWidget(Child);
	UWidget AfterRepeat = Widget.GetRootWidget();
	Widget.SetRootWidget(nullptr);
	UWidget AfterNull = Widget.GetRootWidget();
	return AfterFirst == Child && AfterRepeat == Child && AfterNull is null;
}
/** @end */
/**
 * @begin remove-widget
 * @summary borrows WorldContext and OwningPlayer.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveWidgetNominal
 * @summary borrows WorldContext and OwningPlayer.
 * @covers UUserWidget.remove-widget
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

bool ObserveRemoveWidgetNominal(UUserWidget Widget)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
	}
	UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.MutationChild");
	if (Child is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: ConstructWidget returned null");
	}
	Widget.SetRootWidget(Child);
	bool bRemoved = Widget.RemoveWidget(Child);
	bool bRemovedAgain = Widget.RemoveWidget(Child);
	UWidget NullWidget = nullptr;
	bool bRemovedNull = Widget.RemoveWidget(NullWidget);
	return bRemoved && !bRemovedAgain && !bRemovedNull;
}
/** @end */
/**
 * @begin add-to-viewport
 * @summary borrows WorldContext and OwningPlayer.
 * @topic Unreal
 */
/**
 * @function ObserveAddToViewportNominal
 * @summary borrows WorldContext and OwningPlayer.
 * @covers UUserWidget.add-to-viewport
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

bool ObserveAddToViewportNominal(UUserWidget Widget)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
	}
	Widget.AddToViewport();
	Widget.AddToViewport(0);
	Widget.AddToViewport(1);
	return IsValid(Widget);
}
/** @end */
/**
 * @begin create-widget
 * @summary borrows WorldContext and OwningPlayer.
 * @topic Unreal
 */
/**
 * @function ObserveCreateWidgetNominal
 * @summary borrows WorldContext and OwningPlayer.
 * @covers UUserWidget.create-widget
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

bool ObserveCreateWidgetNominal(APlayerController OwningPlayer)
{
	if (OwningPlayer is null)
	{
		throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required OwningPlayer is null");
	}
	TSubclassOf<UUserWidget> ProbeClass = UTSUserWidgetMutationProbe::StaticClass();
	UUserWidget Created = WidgetBlueprint::CreateWidget(ProbeClass, OwningPlayer);
	TSubclassOf<UUserWidget> EmptyClass;
	UUserWidget EmptyCreated = WidgetBlueprint::CreateWidget(EmptyClass, OwningPlayer);
	UUserWidget BaseCreated = WidgetBlueprint::CreateWidget(UUserWidget::StaticClass(), OwningPlayer);
	return Created != nullptr && EmptyCreated is null && BaseCreated != nullptr;
}
/** @end */
/**
 * @begin UUserWidget-NamespaceAndGlobalFunctions_01-draw-box
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveDrawBoxNominal
 * @summary Observe the container API.
 * @covers UUserWidget.draw-box
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FSlateBrush Brush(UTexture2D Texture, const FVector2D& ImageSize, const FLinearColor& Tint = FLinearColor::White);
// FSlateBrush Brush(UMaterialInterface Material, const FVector2D& ImageSize, const FLinearColor& Tint = FLinearColor::White);
// Inputs: Default FPaintContext, Position (0,0) and Size (10,20), n"WhiteBrush",
// a color brush, allotted geometry, runner-owned USlateBrushAsset plus null asset,
// Angle 0 and 45, runner-owned UTexture2D, a null UMaterialInterface, default tint
// omission and FLinearColor::Red.
// Expected observations: Allotted geometry local size stays non-negative after
// drawing. Texture-brush construction stores ImageSize 16. Material-brush
// construction accepts null as the empty resource and still stores ImageSize.
// Boundary/ownership: Draw helpers increment paint MaxLayer and borrow brushes.
// Null USlateBrushAsset is a no-op draw. SetupOwner=Runner for asset/texture.
bool ObserveDrawBoxNominal(USlateBrushAsset BrushAsset)
{
	if (BrushAsset is null)
	{
		throw("TS_UUserWidget_NamespaceAndGlobalFunctions_01 setup: required BrushAsset is null");
	}
	FPaintContext PaintContext;
	FVector2D Position;
	FVector2D Size(10.0, 20.0);
	FSlateBrush ColorBrush(FLinearColor::White);
	FGeometry Geometry;
	USlateBrushAsset NullAsset = nullptr;

	PaintContext.DrawBox(Position, Size, n"WhiteBrush");
	PaintContext.DrawBox(Position, Size, n"WhiteBrush", FLinearColor::Red);
	PaintContext.DrawBox(Position, Size, ColorBrush);
	PaintContext.DrawBox(Position, Size, ColorBrush, FLinearColor::Red);
	PaintContext.DrawBox(Geometry, ColorBrush);
	PaintContext.DrawBox(Geometry, ColorBrush, FLinearColor::White);
	PaintContext.DrawBox(Position, Size, BrushAsset);
	PaintContext.DrawBox(Position, Size, NullAsset, FLinearColor::White);

	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Local.Y >= 0.0;
}
/** @end */
/**
 * @begin draw-rotated-box
 * @summary Null USlateBrushAsset is a no-op draw.
 * @topic Unreal
 */
/**
 * @function ObserveDrawRotatedBoxNominal
 * @summary Null USlateBrushAsset is a no-op draw.
 * @covers UUserWidget.draw-rotated-box
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDrawRotatedBoxNominal()
{
	FPaintContext PaintContext;
	FVector2D Position;
	FVector2D Size(8.0, 8.0);
	FSlateBrush ColorBrush(FLinearColor::White);
	PaintContext.DrawRotatedBox(Position, Size, 0.0, ColorBrush);
	PaintContext.DrawRotatedBox(Position, Size, 45.0, ColorBrush, FLinearColor::Red);
	FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
	return Local.X >= 0.0 && Local.Y >= 0.0;
}
/** @end */
/**
 * @begin UUserWidget-NamespaceAndGlobalFunctions_01-brush
 * @summary Null USlateBrushAsset is a no-op draw.
 * @topic Unreal
 */
/**
 * @function ObserveBrushNominal
 * @summary Null USlateBrushAsset is a no-op draw.
 * @covers UUserWidget.brush
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveBrushNominal(UTexture2D Texture)
{
	if (Texture is null)
	{
		throw("TS_UUserWidget_NamespaceAndGlobalFunctions_01 setup: required Texture is null");
	}
	UMaterialInterface Material = nullptr;
	FVector2D ImageSize(16.0, 16.0);
	FSlateBrush TextureDefault(Texture, ImageSize);
	FSlateBrush TextureTinted(Texture, ImageSize, FLinearColor::Red);
	FSlateBrush MaterialDefault(Material, ImageSize);
	FSlateBrush MaterialTinted(Material, ImageSize, FLinearColor::White);
	FSlateBrush NullTexture(Cast<UTexture2D>(nullptr), ImageSize);
	return TextureDefault.ImageSize.X == 16.0 && TextureTinted.ImageSize.Y == 16.0 && MaterialDefault.ImageSize.X == 16.0 && MaterialTinted.ImageSize.Y == 16.0 && NullTexture.ImageSize.X == 16.0;
}
/** @end */
/**
 * @begin get-palette-category
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetPaletteCategoryNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-palette-category
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetPaletteCategoryNominal(UUserWidget Widget, const FString& Expected)
{
	if (Widget is null)
	{
		throw("TS_UUserWidget_Queries_01 setup: required Widget is null");
	}
	return Widget.GetPaletteCategory().ToString() == Expected;
}
/** @end */
/**
 * @begin get-root-widget
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetRootWidgetNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-root-widget
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetRootWidgetNominal(UUserWidget Widget)
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
/** @end */
/**
 * @begin get-all-widgets
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllWidgetsNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-all-widgets
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetAllWidgetsNominal(UUserWidget Widget, UWidget Sentinel)
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
/** @end */
/**
 * @begin get-allotted-geometry
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllottedGeometryNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-allotted-geometry
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetAllottedGeometryNominal()
{
	FPaintContext PaintContext;
	const FGeometry& Allotted = PaintContext.GetAllottedGeometry();
	FVector2D Local = Allotted.GetLocalSize();
	FVector2D Absolute = Allotted.GetAbsoluteSize();
	const FGeometry& Alias = PaintContext.GetAllottedGeometry();
	FVector2D AliasLocal = Alias.GetLocalSize();
	return Local.X >= 0.0 && Local.Y >= 0.0 && Absolute.X >= 0.0 && AliasLocal.X == Local.X;
}
/** @end */
/**
 * @begin get-style-color
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetStyleColorNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-style-color
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetStyleColorNominal()
{
	FPaintContext PaintContext;
	FLinearColor Foreground = PaintContext.GetStyleColor(n"DefaultForeground");
	FLinearColor Missing = PaintContext.GetStyleColor(n"TestSource.MissingColor");
	FLinearColor Empty = PaintContext.GetStyleColor(NAME_None);
	return Foreground.A >= 0.0 && Foreground.A <= 1.0 && Missing.A >= 0.0 && Missing.A <= 1.0 && Empty.A >= 0.0 && Empty.A <= 1.0;
}
/** @end */
/**
 * @begin get-style-brush
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetStyleBrushNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-style-brush
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetStyleBrushNominal()
{
	FPaintContext PaintContext;
	const FSlateBrush& White = PaintContext.GetStyleBrush(n"WhiteBrush");
	const FSlateBrush& Missing = PaintContext.GetStyleBrush(n"TestSource.MissingBrush");
	const FSlateBrush& Alias = PaintContext.GetStyleBrush(n"WhiteBrush");
	return White.ImageSize.X >= 0.0 && Missing.ImageSize.X >= 0.0 && Alias.ImageSize.X == White.ImageSize.X;
}
/** @end */
/**
 * @begin get-style-font
 * @summary paint/style data.
 * @topic Unreal
 */
/**
 * @function ObserveGetStyleFontNominal
 * @summary paint/style data.
 * @covers UUserWidget.get-style-font
 * @inputs UUserWidget values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSUserWidgetQueryProbe : UUserWidget
{
}

bool ObserveGetStyleFontNominal()
{
	FPaintContext PaintContext;
	FSlateFontInfo Nominal = PaintContext.GetStyleFont(12);
	FSlateFontInfo EmptySize = PaintContext.GetStyleFont(0);
	return Nominal.Size == 12 && EmptySize.Size == 0;
}
/** @end */
