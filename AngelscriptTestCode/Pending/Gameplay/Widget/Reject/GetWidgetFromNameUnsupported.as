/**
 * @version v1
 * @summary UUserWidget.GetWidgetFromName is not bound, so this program is rejected. C++ compiles it as the module ASCoverageWidget_GetWidgetFromNameUnsupported and expects the diagnostic to name GetWidgetFromName.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary UUserWidget.GetWidgetFromName is not bound, so this program is rejected. C++ compiles it as the module ASCoverageWidget_GetWidgetFromNameUnsupported and expects the diagnostic to name GetWidgetFromName.
 * @topic Negative
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
/** @end */
