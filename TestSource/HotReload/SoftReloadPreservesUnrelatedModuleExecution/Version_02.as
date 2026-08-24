// Theme: HotReload VersionPair Version_02. Unrelated-module B sibling.
// C++: AngelscriptHotReloadPropertyTests.cpp::SoftReloadPreservesUnrelatedModuleExecution ScriptB
// Retained after module A soft reload: GetValueB implementation and result 20.
// Replaced: nothing in this module; A is the only reload target.
// Oracle: GetValueB==20 before and after A reload.
// FixtureIsolated. Load Version_01 (A), Version_02 (B), then Version_03 (A v2).

int GetValueB()
{
	return 20;
}
