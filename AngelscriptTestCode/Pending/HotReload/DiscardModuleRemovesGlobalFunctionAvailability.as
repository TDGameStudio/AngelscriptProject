/**
 * @version v1
 * @summary HotReload VersionPair Before. First global-function module.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. First global-function module.
 * @topic Baseline
 */
// Retained until discard: Entry returns 1.
// Replaced after DiscardModule: this Entry is gone so a second module may publish the same signature.
// FixtureIsolated. C++ ExecuteIntFunction oracle is 1.

/** Script entry point: runs the probe and returns its result. */
int Entry()
{
	return 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Second global-function module, same Entry signature.
 * @topic HotReload
 */
/** Script entry point: runs the probe and returns its result. */
int Entry()
{
	return 2;
}
/** @end */
