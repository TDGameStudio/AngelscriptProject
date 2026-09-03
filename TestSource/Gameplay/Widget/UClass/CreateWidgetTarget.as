/**
 * An empty UUserWidget subclass used as the WidgetBlueprint::CreateWidget target.
 * C++ compiles the class on a fresh engine and then looks up the viewport helpers
 * in a second module, so the class name is part of the contract and is kept
 * verbatim. The empty class is the default vector; viewport calls live in the
 * Function harness.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.CreateWidgetTarget
 * @Harness UClass
 * @Tag Gameplay.Widget.CreateWidgetTarget
 * @Provenance Theme: Gameplay.Widget. Positive compile surface: empty UUserWidget subclass
 * @Provenance used as WidgetBlueprint::CreateWidget target.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::CreateWidgetAndViewportSurface block 1.
 * @Provenance Oracle: UCoverageCreateWidgetTarget compiles. Extra: empty class is the default vector.
 * @Provenance DefaultSafe. Do not invent viewport calls here; they live in _02.
 */

UCLASS()
class UCoverageCreateWidgetTarget : UUserWidget
{
}
