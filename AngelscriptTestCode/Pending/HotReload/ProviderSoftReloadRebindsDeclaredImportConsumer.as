/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Provider module SharedValue 11.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Provider module SharedValue 11.
 * @topic Baseline
 */
/** SharedValue: exercises the shared value behaviour. */
int SharedValue()
{
	return 11;
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Provider body-only soft reload.
 * @topic HotReload
 */
/** SharedValue: exercises the shared value behaviour. */
int SharedValue()
{
	return 29;
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Consumer import of provider SharedValue.
 * @topic HotReload
 */
/** Callable: import int SharedValue() from "HotReload.Dependency.HotReloadDependenc */
import int SharedValue() from "HotReload.Dependency.HotReloadDependencyProvider";

/** Script entry point: runs the probe and returns its result. */
int Entry()
{
	return SharedValue();
}
/** @end */
