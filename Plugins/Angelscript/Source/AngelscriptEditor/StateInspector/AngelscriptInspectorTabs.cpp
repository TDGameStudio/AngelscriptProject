#include "StateInspector/AngelscriptInspectorTabs.h"

#include "StateInspector/SAngelscriptBlueprintImpactWidget.h"
#include "StateInspector/SAngelscriptContentBrowserSourceHealthWidget.h"
#include "StateInspector/SAngelscriptEngineStateWidget.h"
#include "StateInspector/SAngelscriptStateDumpBrowserWidget.h"

#include "Framework/Application/SlateApplication.h"
#include "HAL/IConsoleManager.h"
#include "Widgets/SWindow.h"
#include "Widgets/Text/STextBlock.h"

#define LOCTEXT_NAMESPACE "AngelscriptInspectorTabs"

namespace
{
	constexpr int32 InspectorTabCount = 6;
	TWeakPtr<SWindow> GInspectorWindows[InspectorTabCount];

#if WITH_DEV_AUTOMATION_TESTS
	AngelscriptEditor::StateInspector::FOpenInspectorTabOverride GOpenInspectorTabOverrideForTesting;
#endif

	int32 GetTabIndex(const AngelscriptEditor::StateInspector::EInspectorTab Tab)
	{
		return static_cast<int32>(Tab);
	}

	FText GetTabTitle(const AngelscriptEditor::StateInspector::EInspectorTab Tab)
	{
		using namespace AngelscriptEditor::StateInspector;
		switch (Tab)
		{
		case EInspectorTab::ScriptClassBrowser:
			return LOCTEXT("ScriptClassBrowserTitle", "Angelscript Script Class Browser");
		case EInspectorTab::BindingExplorer:
			return LOCTEXT("BindingExplorerTitle", "Angelscript Binding Explorer");
		case EInspectorTab::CompileDiagnostics:
			return LOCTEXT("CompileDiagnosticsTitle", "Angelscript Compile Diagnostics");
		case EInspectorTab::BlueprintImpactViewer:
			return LOCTEXT("BlueprintImpactViewerTitle", "Angelscript Blueprint Impact Viewer");
		case EInspectorTab::ContentBrowserSourceHealth:
			return LOCTEXT("ContentBrowserSourceHealthTitle", "Angelscript Content Browser / Source Health");
		case EInspectorTab::StateDumpBrowser:
			return LOCTEXT("StateDumpBrowserTitle", "Angelscript State Dump Browser");
		default:
			return LOCTEXT("UnknownInspectorTitle", "Angelscript Inspector");
		}
	}

	TSharedRef<SWidget> CreateInspectorContent(const AngelscriptEditor::StateInspector::EInspectorTab Tab)
	{
		using namespace AngelscriptEditor::StateInspector;
		switch (Tab)
		{
		case EInspectorTab::ScriptClassBrowser:
			return SNew(SAngelscriptEngineStateWidget)
				.InitialSection(SAngelscriptEngineStateWidget::ESection::ScriptClasses)
				.bShowSectionNavigation(false);
		case EInspectorTab::BindingExplorer:
			return SNew(SAngelscriptEngineStateWidget)
				.InitialSection(SAngelscriptEngineStateWidget::ESection::BindDatabase)
				.bShowSectionNavigation(false);
		case EInspectorTab::CompileDiagnostics:
			return SNew(SAngelscriptEngineStateWidget)
				.InitialSection(SAngelscriptEngineStateWidget::ESection::Diagnostics)
				.bShowSectionNavigation(false);
		case EInspectorTab::BlueprintImpactViewer:
			return SNew(SAngelscriptBlueprintImpactWidget);
		case EInspectorTab::ContentBrowserSourceHealth:
			return SNew(SAngelscriptContentBrowserSourceHealthWidget);
		case EInspectorTab::StateDumpBrowser:
			return SNew(SAngelscriptStateDumpBrowserWidget);
		default:
			return SNew(STextBlock).Text(LOCTEXT("UnknownInspectorContent", "Unknown Angelscript inspector."));
		}
	}

	void OpenScriptClassBrowser()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::ScriptClassBrowser);
	}

	void OpenBindingExplorer()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::BindingExplorer);
	}

	void OpenCompileDiagnosticsWindow()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::CompileDiagnostics);
	}

	void OpenBlueprintImpactViewer()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::BlueprintImpactViewer);
	}

	void OpenContentBrowserSourceNavigationHealth()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::ContentBrowserSourceHealth);
	}

	void OpenStateDumpBrowser()
	{
		AngelscriptEditor::StateInspector::OpenInspectorTab(AngelscriptEditor::StateInspector::EInspectorTab::StateDumpBrowser);
	}

	FAutoConsoleCommand GOpenScriptClassBrowserCommand(
		TEXT("as.OpenScriptClassBrowser"),
		TEXT("Open the Angelscript Script Class Browser inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenScriptClassBrowser));

	FAutoConsoleCommand GOpenBindingExplorerCommand(
		TEXT("as.OpenBindingExplorer"),
		TEXT("Open the Angelscript Binding Explorer inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenBindingExplorer));

	FAutoConsoleCommand GOpenCompileDiagnosticsWindowCommand(
		TEXT("as.OpenCompileDiagnosticsWindow"),
		TEXT("Open the Angelscript Compile Diagnostics inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenCompileDiagnosticsWindow));

	FAutoConsoleCommand GOpenBlueprintImpactViewerCommand(
		TEXT("as.OpenBlueprintImpactViewer"),
		TEXT("Open the Angelscript Blueprint Impact Viewer inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenBlueprintImpactViewer));

	FAutoConsoleCommand GOpenContentBrowserSourceNavigationHealthCommand(
		TEXT("as.OpenContentBrowserSourceNavigationHealth"),
		TEXT("Open the Angelscript Content Browser and source navigation health inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenContentBrowserSourceNavigationHealth));

	FAutoConsoleCommand GOpenStateDumpBrowserCommand(
		TEXT("as.OpenStateDumpBrowser"),
		TEXT("Open the Angelscript State Dump Browser inspector window."),
		FConsoleCommandDelegate::CreateStatic(&OpenStateDumpBrowser));
}

namespace AngelscriptEditor::StateInspector
{
	void RegisterInspectorTabs()
	{
	}

	void UnregisterInspectorTabs()
	{
		for (TWeakPtr<SWindow>& Window : GInspectorWindows)
		{
			Window.Reset();
		}
	}

	void OpenInspectorTab(const EInspectorTab Tab)
	{
#if WITH_DEV_AUTOMATION_TESTS
		if (GOpenInspectorTabOverrideForTesting)
		{
			GOpenInspectorTabOverrideForTesting(Tab);
			return;
		}
#endif

		if (!FSlateApplication::IsInitialized())
		{
			return;
		}

		const int32 TabIndex = GetTabIndex(Tab);
		if (TabIndex < 0 || TabIndex >= InspectorTabCount)
		{
			return;
		}

		if (TSharedPtr<SWindow> ExistingWindow = GInspectorWindows[TabIndex].Pin())
		{
			ExistingWindow->BringToFront();
			return;
		}

		TSharedRef<SWindow> NewWindow = SNew(SWindow)
			.Title(GetTabTitle(Tab))
			.ClientSize(FVector2D(1180.0f, 760.0f))
			.SizingRule(ESizingRule::UserSized)
			.SupportsMaximize(true)
			.SupportsMinimize(true)
			.AutoCenter(EAutoCenter::PreferredWorkArea);

		NewWindow->SetContent(CreateInspectorContent(Tab));
		NewWindow->SetOnWindowClosed(FOnWindowClosed::CreateLambda([TabIndex](const TSharedRef<SWindow>&)
		{
			GInspectorWindows[TabIndex].Reset();
		}));

		GInspectorWindows[TabIndex] = NewWindow;
		FSlateApplication::Get().AddWindow(NewWindow);
	}

#if WITH_DEV_AUTOMATION_TESTS
	void SetOpenInspectorTabOverrideForTesting(FOpenInspectorTabOverride InOverride)
	{
		GOpenInspectorTabOverrideForTesting = MoveTemp(InOverride);
	}

	void ResetOpenInspectorTabOverrideForTesting()
	{
		GOpenInspectorTabOverrideForTesting = nullptr;
	}
#endif
}

#undef LOCTEXT_NAMESPACE
