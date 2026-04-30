#pragma once

#include "CoreMinimal.h"

namespace AngelscriptDebugger
{
	struct FLaunchOptions
	{
		FString Host = TEXT("127.0.0.1");
		int32 Port = 27099;
		FString ProjectPath;
		FString ScriptRoot;
		bool bAutoConnect = false;
		bool bSmokeTest = false;
	};

	FLaunchOptions ParseLaunchOptions(const TCHAR* CommandLine);
	FString MakeEnginePreInitCommandLine(const TCHAR* CommandLine);
}
