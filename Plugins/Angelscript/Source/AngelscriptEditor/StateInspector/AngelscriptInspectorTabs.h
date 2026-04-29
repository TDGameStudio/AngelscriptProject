#pragma once

#include "CoreMinimal.h"

namespace AngelscriptEditor::StateInspector
{
	enum class EInspectorTab : uint8
	{
		ScriptClassBrowser,
		BindingExplorer,
		CompileDiagnostics,
		BlueprintImpactViewer,
		ContentBrowserSourceHealth,
		StateDumpBrowser
	};

	void RegisterInspectorTabs();
	void UnregisterInspectorTabs();
	void OpenInspectorTab(EInspectorTab Tab);

#if WITH_DEV_AUTOMATION_TESTS
	using FOpenInspectorTabOverride = TFunction<void(EInspectorTab)>;
	void SetOpenInspectorTabOverrideForTesting(FOpenInspectorTabOverride InOverride);
	void ResetOpenInspectorTabOverrideForTesting();
#endif
}
