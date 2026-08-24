// Theme: Gameplay.Widget. Isolated compile-fail: UUserWidget.GetWidgetFromName
// remains an explicit AngelScript binding boundary.
// C++: AngelscriptCoverageWidgetTests.cpp::GetWidgetFromNameUnsupportedBoundary
// CompileAndExpectFailure. Diagnostic: GetWidgetFromName.
// Do not add extra declarations that would make this compile.

UWidget LookupNamedWidget(UUserWidget Widget)
{
	return Widget.GetWidgetFromName(n"CoverageLookupText");
}
