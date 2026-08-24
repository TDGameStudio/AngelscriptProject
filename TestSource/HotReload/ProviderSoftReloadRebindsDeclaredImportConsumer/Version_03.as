// Theme: HotReload VersionPair Version_03. Consumer import of provider SharedValue.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderSoftReloadRebindsDeclaredImportConsumer
// Retained: import int SharedValue() from HotReload.Dependency.HotReloadDependencyProvider; Entry wrapper.
// Replaced: none on this file; provider Version_01/02 swap the bound implementation.
// Oracle: Entry() 11 then 29. FixtureIsolated. Consumer module, not a provider replacement.

import int SharedValue() from "HotReload.Dependency.HotReloadDependencyProvider";

int Entry()
{
	return SharedValue();
}
