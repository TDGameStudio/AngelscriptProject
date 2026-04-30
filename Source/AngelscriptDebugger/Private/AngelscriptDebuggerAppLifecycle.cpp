#include "AngelscriptDebuggerAppLifecycle.h"

#include "CoreGlobals.h"
#include "Framework/Application/SlateApplication.h"
#include "HAL/PlatformProcess.h"
#include "HAL/PlatformTime.h"
#include "LaunchEngineLoop.h"
#include "StandaloneRenderer.h"
#include "Widgets/SWindow.h"

namespace AngelscriptDebugger
{
	FStandaloneSlateDebuggerLifecycle::FStandaloneSlateDebuggerLifecycle(TSharedPtr<IWindowController>& InWindowController)
		: WindowController(InWindowController)
	{
	}

	FStandaloneSlateDebuggerLifecycle::~FStandaloneSlateDebuggerLifecycle()
	{
		if (WindowController.IsValid())
		{
			WindowController->ShutdownSession();
			WindowController.Reset();
		}
		if (FSlateApplication::IsInitialized())
		{
			FSlateApplication::Shutdown();
		}
		if (GLog != nullptr)
		{
			GLog->Flush();
		}
	}

	void FStandaloneSlateDebuggerLifecycle::Initialize()
	{
		if (!FSlateApplication::IsInitialized())
		{
			FSlateApplication::InitializeAsStandaloneApplication(GetStandardStandaloneRenderer());
		}
		FSlateApplication::Get().UnregisterGameViewport();
		FSlateApplication::Get().SetExitRequestedHandler(FSimpleDelegate::CreateRaw(this, &FStandaloneSlateDebuggerLifecycle::HandleExitRequested));
	}

	int32 FStandaloneSlateDebuggerLifecycle::RunLoop(const TSharedRef<SWindow>& MainWindow, const FStandaloneSlateLoopOptions& Options)
	{
		bExitRequested = false;
		bMainWindowClosed = false;

		MainWindow->SetRequestDestroyWindowOverride(FRequestDestroyWindowOverride::CreateRaw(this, &FStandaloneSlateDebuggerLifecycle::HandleRequestDestroyWindow));
		MainWindow->SetOnWindowClosed(FOnWindowClosed::CreateRaw(this, &FStandaloneSlateDebuggerLifecycle::HandleWindowClosed));
		FSlateApplication::Get().AddWindow(MainWindow);

		const double SmokeTestStartTime = FPlatformTime::Seconds();
		bool bSmokeTestCloseRequested = false;
		while (!IsEngineExitRequested() && !bExitRequested && !bMainWindowClosed)
		{
			FSlateApplication::Get().PumpMessages();
			FSlateApplication::Get().Tick();
			if (Options.bSmokeTest
				&& !bSmokeTestCloseRequested
				&& FPlatformTime::Seconds() - SmokeTestStartTime >= Options.SmokeTestCloseDelaySeconds)
			{
				bSmokeTestCloseRequested = true;
				MainWindow->RequestDestroyWindow();
			}
			if (!MainWindow->IsVisible() || !MainWindow->GetNativeWindow().IsValid())
			{
				break;
			}
			FPlatformProcess::Sleep(0.01f);
		}

		return 0;
	}

	void FStandaloneSlateDebuggerLifecycle::HandleExitRequested()
	{
		bExitRequested = true;
	}

	void FStandaloneSlateDebuggerLifecycle::HandleRequestDestroyWindow(const TSharedRef<SWindow>& WindowToDestroy)
	{
		bMainWindowClosed = true;
		if (FSlateApplication::IsInitialized())
		{
			FSlateApplication::Get().RequestDestroyWindow(WindowToDestroy);
		}
	}

	void FStandaloneSlateDebuggerLifecycle::HandleWindowClosed(const TSharedRef<SWindow>&)
	{
		bMainWindowClosed = true;
	}
}
