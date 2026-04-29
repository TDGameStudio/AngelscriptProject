#include "Core/AngelscriptEditorModule.h"

#include "StateInspector/SAngelscriptEngineStateWidget.h"

#include "Framework/Application/SlateApplication.h"
#include "HAL/IConsoleManager.h"
#include "Widgets/SWindow.h"

#define LOCTEXT_NAMESPACE "AngelscriptEngineStateWindow"

namespace
{
	TWeakPtr<SWindow> GAngelscriptEngineStateWindow;

#if WITH_DEV_AUTOMATION_TESTS
	TFunction<void()> GShowEngineStateWindowOverrideForTesting;
#endif
}

void FAngelscriptEditorModule::ShowEngineStateWindow()
{
#if WITH_DEV_AUTOMATION_TESTS
	if (GShowEngineStateWindowOverrideForTesting)
	{
		GShowEngineStateWindowOverrideForTesting();
		return;
	}
#endif

	if (!FSlateApplication::IsInitialized())
	{
		return;
	}

	if (TSharedPtr<SWindow> ExistingWindow = GAngelscriptEngineStateWindow.Pin())
	{
		ExistingWindow->BringToFront();
		return;
	}

	TSharedRef<SWindow> NewWindow = SNew(SWindow)
		.Title(LOCTEXT("WindowTitle", "Angelscript Engine State"))
		.ClientSize(FVector2D(1280.0f, 800.0f))
		.SizingRule(ESizingRule::UserSized)
		.SupportsMaximize(true)
		.SupportsMinimize(true)
		.AutoCenter(EAutoCenter::PreferredWorkArea);

	NewWindow->SetContent(SNew(SAngelscriptEngineStateWidget));
	NewWindow->SetOnWindowClosed(FOnWindowClosed::CreateLambda([](const TSharedRef<SWindow>&)
	{
		GAngelscriptEngineStateWindow.Reset();
	}));

	GAngelscriptEngineStateWindow = NewWindow;
	FSlateApplication::Get().AddWindow(NewWindow);
}

namespace
{
	FAutoConsoleCommand GOpenAngelscriptEngineStateWindowCommand(
		TEXT("as.OpenEngineStateWindow"),
		TEXT("Open the Angelscript editor engine state inspector window."),
		FConsoleCommandDelegate::CreateStatic(&FAngelscriptEditorModule::ShowEngineStateWindow));
}

#if WITH_DEV_AUTOMATION_TESTS
void FAngelscriptEditorModuleTestAccess::SetEngineStateWindowOpenOverride(TFunction<void()> InOverride)
{
	GShowEngineStateWindowOverrideForTesting = MoveTemp(InOverride);
}

void FAngelscriptEditorModuleTestAccess::ResetEngineStateWindowOpenOverride()
{
	GShowEngineStateWindowOverrideForTesting = nullptr;
}
#endif

#undef LOCTEXT_NAMESPACE
