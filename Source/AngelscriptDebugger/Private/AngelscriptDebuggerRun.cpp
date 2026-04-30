#include "AngelscriptDebuggerRun.h"

#include "AngelscriptDebuggerAppLifecycle.h"
#include "AngelscriptDebuggerCommandLine.h"
#include "SAngelscriptDebuggerWindow.h"
#include "CoreGlobals.h"
#include "HAL/PlatformTLS.h"
#include "LaunchEngineLoop.h"
#include "Misc/CommandLine.h"
#include "Widgets/SWindow.h"

int32 RunAngelscriptDebugger(const TCHAR* CommandLine)
{
	FTaskTagScope Scope(ETaskTag::EGameThread);
	GGameThreadId = FPlatformTLS::GetCurrentThreadId();
	GIsGameThreadIdInitialized = true;
	FCommandLine::Set(CommandLine);

	const AngelscriptDebugger::FLaunchOptions LaunchOptions = AngelscriptDebugger::ParseLaunchOptions(CommandLine);
	const FString PreInitCommandLine = AngelscriptDebugger::MakeEnginePreInitCommandLine(CommandLine);

	const int32 PreInitResult = GEngineLoop.PreInit(*PreInitCommandLine);
	if (PreInitResult != 0 || IsEngineExitRequested())
	{
		return PreInitResult;
	}

	TSharedPtr<AngelscriptDebugger::IWindowController> DebuggerWindow;
	AngelscriptDebugger::FStandaloneSlateDebuggerLifecycle Lifecycle(DebuggerWindow);
	Lifecycle.Initialize();

	TSharedRef<SWindow> MainWindow = SNew(SWindow)
		.Title(FText::FromString(TEXT("Angelscript Debugger")))
		.ClientSize(FVector2D(1500.0f, 900.0f))
		.SizingRule(ESizingRule::UserSized)
		.SupportsMaximize(true)
		.SupportsMinimize(true)
		.AutoCenter(EAutoCenter::PreferredWorkArea);

	AngelscriptDebugger::FWindowArgs WindowArgs;
	WindowArgs.InitialHost = LaunchOptions.Host;
	WindowArgs.InitialPort = LaunchOptions.Port;
	WindowArgs.ProjectPath = LaunchOptions.ProjectPath;
	WindowArgs.ScriptRoot = LaunchOptions.ScriptRoot;
	WindowArgs.bAutoConnect = LaunchOptions.bAutoConnect;
	DebuggerWindow = AngelscriptDebugger::CreateWindowController(WindowArgs);
	MainWindow->SetContent(DebuggerWindow->GetWidget());

	AngelscriptDebugger::FStandaloneSlateLoopOptions LoopOptions;
	LoopOptions.bSmokeTest = LaunchOptions.bSmokeTest;
	return Lifecycle.RunLoop(MainWindow, LoopOptions);
}
