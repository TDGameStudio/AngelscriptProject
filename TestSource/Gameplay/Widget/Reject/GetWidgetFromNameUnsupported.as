/**
 * UUserWidget.GetWidgetFromName is not bound, so this program is rejected. C++
 * compiles it as the module ASCoverageWidget_GetWidgetFromNameUnsupported and
 * expects the diagnostic to name GetWidgetFromName.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.GetWidgetFromNameUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Widget.GetWidgetFromNameUnsupported
 * @Provenance Theme: Gameplay.Widget. Isolated compile-fail: UUserWidget.GetWidgetFromName
 * @Provenance remains an explicit AngelScript binding boundary.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::GetWidgetFromNameUnsupportedBoundary
 * @Provenance CompileAndExpectFailure. Diagnostic: GetWidgetFromName.
 * @Provenance Do not add extra declarations that would make this compile.
 */

/**
 * The isolated failing program: GetWidgetFromName has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Widget.GetWidgetFromNameUnsupported
 * @Inputs a user widget whose named child is looked up
 * @Return does not compile; GetWidgetFromName is not bound
 * @Param Widget the user widget to search
 */
UWidget LookupNamedWidget(UUserWidget Widget)
{
	return Widget.GetWidgetFromName(n"CoverageLookupText");
}
