#pragma once

#include "AngelscriptDebuggerViewModels.h"
#include "CoreMinimal.h"
#include "Debugging/AngelscriptDebugProtocol.h"

namespace AngelscriptDebugger
{
	class FClient
	{
	public:
		FClient();
		~FClient();

		bool Connect(const FString& InHost, int32 InPort);
		void Disconnect();
		void Tick();
		bool IsConnected() const;
		FText GetStatusText() const;
		TArray<FDebuggerClientEvent> DrainEvents();

		void SendEmpty(EDebugMessageType MessageType);
		void SendRequestVariables(const FString& ScopePath);
		void SendRequestEvaluate(const FString& Path, int32 DefaultFrame);
		void SendSetBreakpoint(int32 Id, const FString& Filename, const FString& ModuleName, int32 LineNumber, const FString& Condition);
		void SendClearBreakpoints(const FString& Filename, const FString& ModuleName);
		void SendBreakOptions(const TArray<FString>& Filters);
		void SendSetDataBreakpoints(const TArray<FDataBreakpointView>& Breakpoints);

	private:
		class FImpl;
		TUniquePtr<FImpl> Impl;
	};
}
