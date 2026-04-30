#pragma once

#include "CoreMinimal.h"
#include "Templates/SharedPointer.h"

class SWidget;

namespace AngelscriptDebugger
{
	struct FWindowArgs
	{
		FString InitialHost = TEXT("127.0.0.1");
		int32 InitialPort = 27099;
		FString ProjectPath;
		FString ScriptRoot;
		bool bAutoConnect = false;
	};

	class IWindowController
	{
	public:
		virtual ~IWindowController() = default;

		virtual TSharedRef<SWidget> GetWidget() const = 0;
		virtual void ShutdownSession() = 0;
	};

	TSharedRef<IWindowController> CreateWindowController(const FWindowArgs& Args);
}
