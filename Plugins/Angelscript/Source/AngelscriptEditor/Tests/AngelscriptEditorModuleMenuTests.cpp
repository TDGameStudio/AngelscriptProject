#include "Core/AngelscriptEditorModule.h"

#include "StateInspector/AngelscriptInspectorTabs.h"

#include "HAL/IConsoleManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "ToolMenu.h"
#include "ToolMenuEntry.h"
#include "ToolMenuOwner.h"
#include "ToolMenuSection.h"
#include "ToolMenus.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorModuleRegisterToolsMenuEntriesTest,
	"Angelscript.Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptEditor_Private_Tests_AngelscriptEditorModuleMenuTests_Private
{
	struct FPlatformExecuteCall
	{
		FString CommandType;
		FString Command;
		FString CommandLine;
	};

	const FToolMenuEntry* FindOwnedEntry(const FToolMenuSection& Section, const FName EntryName, const FToolMenuOwner Owner)
	{
		return Section.Blocks.FindByPredicate([EntryName, Owner](const FToolMenuEntry& Entry)
		{
			return Entry.Name == EntryName && Entry.Owner == Owner;
		});
	}

	int32 CountOwnedEntries(const FToolMenuSection& Section, const FToolMenuOwner Owner)
	{
		int32 Count = 0;
		for (const FToolMenuEntry& Entry : Section.Blocks)
		{
			if (Entry.Owner == Owner)
			{
				++Count;
			}
		}

		return Count;
	}
}

using namespace AngelscriptEditor_Private_Tests_AngelscriptEditorModuleMenuTests_Private;

bool FAngelscriptEditorModuleRegisterToolsMenuEntriesTest::RunTest(const FString& Parameters)
{
	UToolMenus* ToolMenus = UToolMenus::Get();
	if (!TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should resolve tool menus"), ToolMenus))
	{
		return false;
	}

	UToolMenu* ToolsMenu = ToolMenus->ExtendMenu("MainFrame.MainMenu.Tools");
	if (!TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should resolve the main Tools menu"), ToolsMenu))
	{
		return false;
	}

	FAngelscriptEditorModule Module;
	const FToolMenuOwner ModuleOwner(&Module);
	TArray<FPlatformExecuteCall> PlatformExecuteCalls;
	TArray<AngelscriptEditor::StateInspector::EInspectorTab> OpenedInspectorTabs;
	int32 EngineStateWindowOpenCalls = 0;

	FAngelscriptEditorModuleTestAccess::ResetPlatformExecuteOverride();
	FAngelscriptEditorModuleTestAccess::ResetEngineStateWindowOpenOverride();
	AngelscriptEditor::StateInspector::ResetOpenInspectorTabOverrideForTesting();
	UToolMenus::UnregisterOwner(&Module);

	ON_SCOPE_EXIT
	{
		FAngelscriptEditorModuleTestAccess::ResetPlatformExecuteOverride();
		FAngelscriptEditorModuleTestAccess::ResetEngineStateWindowOpenOverride();
		AngelscriptEditor::StateInspector::ResetOpenInspectorTabOverrideForTesting();
		UToolMenus::UnregisterOwner(&Module);
	};

	FAngelscriptEditorModuleTestAccess::SetPlatformExecuteOverride(
		[&PlatformExecuteCalls](const TCHAR* CommandType, const TCHAR* Command, const TCHAR* CommandLine)
		{
			FPlatformExecuteCall& Call = PlatformExecuteCalls.AddDefaulted_GetRef();
			Call.CommandType = CommandType != nullptr ? CommandType : TEXT("");
			Call.Command = Command != nullptr ? Command : TEXT("");
			Call.CommandLine = CommandLine != nullptr ? CommandLine : TEXT("");
			return true;
		});
	FAngelscriptEditorModuleTestAccess::SetEngineStateWindowOpenOverride([&EngineStateWindowOpenCalls]()
	{
		++EngineStateWindowOpenCalls;
	});
	AngelscriptEditor::StateInspector::SetOpenInspectorTabOverrideForTesting([&OpenedInspectorTabs](const AngelscriptEditor::StateInspector::EInspectorTab Tab)
	{
		OpenedInspectorTabs.Add(Tab);
	});

	FAngelscriptEditorModuleTestAccess::RegisterToolsMenuEntries(Module);

	FToolMenuSection* ProgrammingSection = ToolsMenu->FindSection("Programming");
	FToolMenuSection* InspectorsSection = ToolsMenu->FindSection("Angelscript Inspectors");
	FToolMenuSection* ProgrammingBindsSection = ToolsMenu->FindSection("Programming Binds");
	if (!TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should create the Programming section"), ProgrammingSection)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should create the Angelscript Inspectors section"), InspectorsSection)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should create the Programming Binds section"), ProgrammingBindsSection))
	{
		return false;
	}

	const FToolMenuEntry* OpenCodeEntry = FindOwnedEntry(*ProgrammingSection, "ASOpenCode", ModuleOwner);
	const FToolMenuEntry* OpenEngineStateEntry = FindOwnedEntry(*ProgrammingSection, "ASOpenEngineState", ModuleOwner);
	const FToolMenuEntry* FunctionTestsEntry = FindOwnedEntry(*ProgrammingSection, "Function Tests", ModuleOwner);
	const FToolMenuEntry* ScriptClassBrowserEntry = FindOwnedEntry(*InspectorsSection, "ASOpenScriptClassBrowser", ModuleOwner);
	const FToolMenuEntry* BindingExplorerEntry = FindOwnedEntry(*InspectorsSection, "ASOpenBindingExplorer", ModuleOwner);
	const FToolMenuEntry* CompileDiagnosticsEntry = FindOwnedEntry(*InspectorsSection, "ASOpenCompileDiagnostics", ModuleOwner);
	const FToolMenuEntry* BlueprintImpactEntry = FindOwnedEntry(*InspectorsSection, "ASOpenBlueprintImpact", ModuleOwner);
	const FToolMenuEntry* ContentBrowserSourceHealthEntry = FindOwnedEntry(*InspectorsSection, "ASOpenContentBrowserSourceHealth", ModuleOwner);
	const FToolMenuEntry* StateDumpBrowserEntry = FindOwnedEntry(*InspectorsSection, "ASOpenStateDumpBrowser", ModuleOwner);
	const FToolMenuEntry* GenerateBindingsEntry = FindOwnedEntry(*ProgrammingBindsSection, "ASGenerateBindings", ModuleOwner);
	if (!TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenCode in the Programming section"), OpenCodeEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenEngineState in the Programming section"), OpenEngineStateEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register Function Tests in the Programming section"), FunctionTestsEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenScriptClassBrowser"), ScriptClassBrowserEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenBindingExplorer"), BindingExplorerEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenCompileDiagnostics"), CompileDiagnosticsEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenBlueprintImpact"), BlueprintImpactEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenContentBrowserSourceHealth"), ContentBrowserSourceHealthEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASOpenStateDumpBrowser"), StateDumpBrowserEntry)
		|| !TestNotNull(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register ASGenerateBindings in the Programming Binds section"), GenerateBindingsEntry))
	{
		return false;
	}

	if (!TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should contribute exactly three entries to the Programming section"), CountOwnedEntries(*ProgrammingSection, ModuleOwner), 3)
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should contribute exactly six entries to the Angelscript Inspectors section"), CountOwnedEntries(*InspectorsSection, ModuleOwner), 6)
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should contribute exactly one entry to the Programming Binds section"), CountOwnedEntries(*ProgrammingBindsSection, ModuleOwner), 1))
	{
		return false;
	}

	if (!TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the workspace label"), OpenCodeEntry->Label.Get().ToString(), FString(TEXT("Open Angelscript workspace (VS Code)")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the engine-state label"), OpenEngineStateEntry->Label.Get().ToString(), FString(TEXT("Open Angelscript Engine State")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the function-tests label"), FunctionTestsEntry->Label.Get().ToString(), FString(TEXT("Run Function Tests")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the script-class browser label"), ScriptClassBrowserEntry->Label.Get().ToString(), FString(TEXT("Script Class Browser")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the binding explorer label"), BindingExplorerEntry->Label.Get().ToString(), FString(TEXT("Binding Explorer")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the compile diagnostics label"), CompileDiagnosticsEntry->Label.Get().ToString(), FString(TEXT("Compile Diagnostics")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the blueprint impact label"), BlueprintImpactEntry->Label.Get().ToString(), FString(TEXT("Blueprint Impact Viewer")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the source health label"), ContentBrowserSourceHealthEntry->Label.Get().ToString(), FString(TEXT("Content Browser / Source Navigation Health")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the state dump browser label"), StateDumpBrowserEntry->Label.Get().ToString(), FString(TEXT("State Dump Browser / Diff")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should preserve the legacy-bind label"), GenerateBindingsEntry->Label.Get().ToString(), FString(TEXT("Legacy Native Bind Generator (Debug Only)"))))
	{
		return false;
	}

	FToolMenuEntry* MutableOpenCodeEntry = const_cast<FToolMenuEntry*>(OpenCodeEntry);
	const bool bExecuted = MutableOpenCodeEntry->TryExecuteToolUIAction(FToolMenuContext());
	if (!TestTrue(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should execute the ASOpenCode action"), bExecuted)
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should call platform execute exactly once"), PlatformExecuteCalls.Num(), 1))
	{
		return false;
	}

	const FString ExpectedScriptCommandLine = FString::Printf(TEXT("\"%s\""), *(FPaths::ProjectDir() / TEXT("Script")));
	if (!TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should keep the command type empty"), PlatformExecuteCalls[0].CommandType, FString())
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should launch VS Code"), PlatformExecuteCalls[0].Command, FString(TEXT("code")))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should target the project Script workspace"), PlatformExecuteCalls[0].CommandLine, ExpectedScriptCommandLine))
	{
		return false;
	}

	FToolMenuEntry* MutableOpenEngineStateEntry = const_cast<FToolMenuEntry*>(OpenEngineStateEntry);
	if (!TestTrue(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should execute the ASOpenEngineState action"), MutableOpenEngineStateEntry->TryExecuteToolUIAction(FToolMenuContext()))
		|| !TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should call the engine-state window hook exactly once"), EngineStateWindowOpenCalls, 1))
	{
		return false;
	}

	const TArray<const FToolMenuEntry*> InspectorEntries = {
		ScriptClassBrowserEntry,
		BindingExplorerEntry,
		CompileDiagnosticsEntry,
		BlueprintImpactEntry,
		ContentBrowserSourceHealthEntry,
		StateDumpBrowserEntry
	};
	for (const FToolMenuEntry* InspectorEntry : InspectorEntries)
	{
		if (!TestTrue(
			*FString::Printf(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should execute inspector entry '%s'"), *InspectorEntry->Name.ToString()),
			const_cast<FToolMenuEntry*>(InspectorEntry)->TryExecuteToolUIAction(FToolMenuContext())))
		{
			return false;
		}
	}

	if (!TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should open every inspector tab once"), OpenedInspectorTabs.Num(), 6))
	{
		return false;
	}

	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route Script Class Browser"), OpenedInspectorTabs[0], AngelscriptEditor::StateInspector::EInspectorTab::ScriptClassBrowser);
	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route Binding Explorer"), OpenedInspectorTabs[1], AngelscriptEditor::StateInspector::EInspectorTab::BindingExplorer);
	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route Compile Diagnostics"), OpenedInspectorTabs[2], AngelscriptEditor::StateInspector::EInspectorTab::CompileDiagnostics);
	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route Blueprint Impact Viewer"), OpenedInspectorTabs[3], AngelscriptEditor::StateInspector::EInspectorTab::BlueprintImpactViewer);
	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route Content Browser / Source Navigation Health"), OpenedInspectorTabs[4], AngelscriptEditor::StateInspector::EInspectorTab::ContentBrowserSourceHealth);
	TestEqual(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should route State Dump Browser"), OpenedInspectorTabs[5], AngelscriptEditor::StateInspector::EInspectorTab::StateDumpBrowser);

	const TCHAR* ExpectedConsoleCommands[] = {
		TEXT("as.OpenScriptClassBrowser"),
		TEXT("as.OpenBindingExplorer"),
		TEXT("as.OpenCompileDiagnosticsWindow"),
		TEXT("as.OpenBlueprintImpactViewer"),
		TEXT("as.OpenContentBrowserSourceNavigationHealth"),
		TEXT("as.OpenStateDumpBrowser")
	};
	for (const TCHAR* ExpectedConsoleCommand : ExpectedConsoleCommands)
	{
		if (!TestNotNull(
			*FString::Printf(TEXT("Editor.Module.RegisterToolsMenuEntriesAddsWorkspaceStateAndLegacyBindCommands should register console command '%s'"), ExpectedConsoleCommand),
			IConsoleManager::Get().FindConsoleObject(ExpectedConsoleCommand)))
		{
			return false;
		}
	}

	return true;
}

#endif
