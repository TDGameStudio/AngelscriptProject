/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Unrelated-module A before reload.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Unrelated-module A before reload.
 * @topic Baseline
 */
// Retained across the trio: module B GetValueB==20 (Version_02 is never reloaded).
// Replaced in Version_03: GetValueA 10 -> 11.
// Oracle Before: GetValueA==10.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

/** Returns the value a. */
int GetValueA()
{
	return 10;
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Unrelated-module B sibling.
 * @topic HotReload
 */
// Retained after module A soft reload: GetValueB implementation and result 20.
// Replaced: nothing in this module; A is the only reload target.
// Oracle: GetValueB==20 before and after A reload.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

/** Returns the value b. */
int GetValueB()
{
	return 20;
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Unrelated-module A after soft reload.
 * @topic HotReload
 */
// Oracle After: GetValueA==11; GetValueB still 20; SoftReloadOnly handled.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

/** Returns the value a. */
int GetValueA()
{
	return 11;
}
/** @end */
