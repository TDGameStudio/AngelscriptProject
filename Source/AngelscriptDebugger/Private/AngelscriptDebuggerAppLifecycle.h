#pragma once

#include "CoreMinimal.h"
#include "SAngelscriptDebuggerWindow.h"
#include "Templates/SharedPointer.h"

class SWindow;

namespace AngelscriptDebugger
{
	struct FStandaloneSlateLoopOptions
	{
		bool bSmokeTest = false;
		double SmokeTestCloseDelaySeconds = 2.0;
	};

	class FStandaloneSlateDebuggerLifecycle final
	{
	public:
		explicit FStandaloneSlateDebuggerLifecycle(TSharedPtr<IWindowController>& InWindowController);
		~FStandaloneSlateDebuggerLifecycle();

		void Initialize();
		int32 RunLoop(const TSharedRef<SWindow>& MainWindow, const FStandaloneSlateLoopOptions& Options);

	private:
		void HandleExitRequested();
		void HandleRequestDestroyWindow(const TSharedRef<SWindow>& WindowToDestroy);
		void HandleWindowClosed(const TSharedRef<SWindow>& Window);

		TSharedPtr<IWindowController>& WindowController;
		bool bExitRequested = false;
		bool bMainWindowClosed = false;
	};
}
