#include "AngelscriptDebuggerRun.h"

#include "CoreMinimal.h"
#include "HAL/ExceptionHandling.h"
#include "LaunchEngineLoop.h"
#include "Misc/OutputDeviceError.h"
#include "Windows/WindowsHWrapper.h"

#include <shellapi.h>

static FString GSavedAngelscriptDebuggerCommandLine;

static bool ProcessAngelscriptDebuggerCommandLine()
{
	int ArgCount = 0;
	LPWSTR* Args = ::CommandLineToArgvW(::GetCommandLineW(), &ArgCount);
	if (Args == nullptr)
	{
		return false;
	}

	GSavedAngelscriptDebuggerCommandLine.Reset();
	for (int32 Index = 1; Index < ArgCount; ++Index)
	{
		GSavedAngelscriptDebuggerCommandLine += TEXT(" ");

		FString Argument = Args[Index];
		if (Argument.Contains(TEXT(" ")))
		{
			int32 QuoteIndex = 0;
			if (Argument.StartsWith(TEXT("-")))
			{
				int32 SeparatorIndex = INDEX_NONE;
				if (Argument.FindChar(TEXT('='), SeparatorIndex))
				{
					QuoteIndex = SeparatorIndex + 1;
				}
			}
			Argument = Argument.Left(QuoteIndex) + TEXT("\"") + Argument.Mid(QuoteIndex) + TEXT("\"");
		}
		GSavedAngelscriptDebuggerCommandLine += Argument;
	}

	::LocalFree(Args);
	return true;
}

static int32 ExitAngelscriptDebuggerProcess(const int32 ErrorLevel)
{
	const uint8 ReturnCode = static_cast<uint8>(FMath::Clamp(ErrorLevel, 0, 255));
	FEngineLoop::AppExit();
	// This target runs editor PreInit plus a standalone Slate loop; returning through CRT shutdown
	// can touch editor DLL statics after their modules have already begun teardown.
	::TerminateProcess(::GetCurrentProcess(), ReturnCode);
	return ReturnCode;
}

int32 WINAPI WinMain(_In_ HINSTANCE hInInstance, _In_opt_ HINSTANCE hPrevInstance, _In_ char* CmdLineAnsi, _In_ int32 nShowCmd)
{
	hInstance = hInInstance;

	const TCHAR* CommandLine = ::GetCommandLineW();
	if (ProcessAngelscriptDebuggerCommandLine())
	{
		CommandLine = *GSavedAngelscriptDebuggerCommandLine;
	}

#if !UE_BUILD_SHIPPING
	if (FParse::Param(CommandLine, TEXT("crashreports")))
	{
		GAlwaysReportCrash = true;
	}
#endif

	int32 ErrorLevel = 0;

#if UE_BUILD_DEBUG
	if (!GAlwaysReportCrash)
#else
	if (FPlatformMisc::IsDebuggerPresent() && !GAlwaysReportCrash)
#endif
	{
		ErrorLevel = RunAngelscriptDebugger(CommandLine);
	}
	else
	{
#if !PLATFORM_SEH_EXCEPTIONS_DISABLED
		__try
#endif
		{
			GIsGuarded = 1;
			ErrorLevel = RunAngelscriptDebugger(CommandLine);
			GIsGuarded = 0;
		}
#if !PLATFORM_SEH_EXCEPTIONS_DISABLED
		__except (ReportCrash(GetExceptionInformation()))
		{
			ErrorLevel = 1;
			GError->HandleError();
			FPlatformMisc::RequestExit(true);
		}
#endif
	}

	return ExitAngelscriptDebuggerProcess(ErrorLevel);
}
