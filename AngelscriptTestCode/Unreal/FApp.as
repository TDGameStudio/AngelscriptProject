/**
 * @version v1
 * @summary FApp host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FApp
 *
 * can-ever-render
 * get-project-name
 */
/**
 * @begin can-ever-render
 * @summary returns a new FString and does not own engine identity.
 * @topic Unreal
 */
/**
 * @function ObserveCanEverRenderNominal
 * @summary returns a new FString and does not own engine identity.
 * @covers FApp.can-ever-render
 * @inputs FApp values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCanEverRenderNominal(bool bExpectCanRender)
{
	return FApp::CanEverRender() == bExpectCanRender;
}
/** @end */
/**
 * @begin get-project-name
 * @summary returns a new FString and does not own engine identity.
 * @topic Unreal
 */
/**
 * @function ObserveGetProjectNameNominal
 * @summary returns a new FString and does not own engine identity.
 * @covers FApp.get-project-name
 * @inputs FApp values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetProjectNameNominal()
{
	FString First = FApp::GetProjectName();
	FString Second = FApp::GetProjectName();
	return First == Second && First.Len() > 0;
}
/** @end */
