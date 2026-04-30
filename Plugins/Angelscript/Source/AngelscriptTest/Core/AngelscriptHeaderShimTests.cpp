#include "../../AngelscriptRuntime/Core/AngelscriptInclude.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptHeaderShimTests_Private
{
	struct FNativeMessageEntry
	{
		FString Section;
		int32 Row = 0;
		int32 Column = 0;
		FString Message;
	};

	struct FNativeMessageCollector
	{
		TArray<FNativeMessageEntry> Entries;

		static void Callback(const asSMessageInfo* MessageInfo, void* UserData)
		{
			if (MessageInfo == nullptr || UserData == nullptr)
			{
				return;
			}

			FNativeMessageCollector* Collector = static_cast<FNativeMessageCollector*>(UserData);
			FNativeMessageEntry Entry;
			Entry.Section = UTF8_TO_TCHAR(MessageInfo->section != nullptr ? MessageInfo->section : "");
			Entry.Row = MessageInfo->row;
			Entry.Column = MessageInfo->col;
			Entry.Message = UTF8_TO_TCHAR(MessageInfo->message != nullptr ? MessageInfo->message : "");
			Collector->Entries.Add(MoveTemp(Entry));
		}

		FString Format() const
		{
			FString Result;
			for (const FNativeMessageEntry& Entry : Entries)
			{
				if (!Result.IsEmpty())
				{
					Result += LINE_TERMINATOR;
				}

				Result += FString::Printf(
					TEXT("%s:%d:%d %s"),
					Entry.Section.IsEmpty() ? TEXT("<memory>") : *Entry.Section,
					Entry.Row,
					Entry.Column,
					*Entry.Message);
			}

			return Result.IsEmpty() ? TEXT("<no native AngelScript diagnostics>") : Result;
		}
	};

	template<typename TObjectType>
	struct TScopedAsRelease
	{
		TObjectType* Object = nullptr;

		explicit TScopedAsRelease(TObjectType* InObject)
			: Object(InObject)
		{
		}

		~TScopedAsRelease()
		{
			if (Object != nullptr)
			{
				Object->Release();
			}
		}
	};

	struct FScopedAsEngineRelease
	{
		asIScriptEngine* Engine = nullptr;

		explicit FScopedAsEngineRelease(asIScriptEngine* InEngine)
			: Engine(InEngine)
		{
		}

		~FScopedAsEngineRelease()
		{
			if (Engine != nullptr)
			{
				Engine->ShutDownAndRelease();
			}
		}
	};
}


TEST_CLASS_WITH_FLAGS(FAngelscriptHeaderShimTests,
	"Angelscript.TestModule.Engine.HeaderShim",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(RawAngelscriptApiRoundTrip)
	{
		using namespace AngelscriptTest_Core_AngelscriptHeaderShimTests_Private;
		const ANSICHAR* RawLibraryVersion = asGetLibraryVersion();
		if (!TestRunner->TestNotNull(TEXT("HeaderShim native API test should expose a library version string"), RawLibraryVersion))
		{
			return;
		}

		const FString LibraryVersion = ANSI_TO_TCHAR(RawLibraryVersion);
		if (!TestRunner->TestFalse(TEXT("HeaderShim native API test should expose a non-empty library version string"), LibraryVersion.IsEmpty()))
		{
			return;
		}

		FNativeMessageCollector MessageCollector;
		asIScriptEngine* NativeEngine = asCreateScriptEngine(ANGELSCRIPT_VERSION);
		if (!TestRunner->TestNotNull(TEXT("HeaderShim native API test should create a raw AngelScript engine"), NativeEngine))
		{
			return;
		}

		FScopedAsEngineRelease EngineScope(NativeEngine);

		const int32 CallbackResult = NativeEngine->SetMessageCallback(
			asFUNCTION(FNativeMessageCollector::Callback),
			&MessageCollector,
			asCALL_CDECL);
		if (!TestRunner->TestEqual(TEXT("HeaderShim native API test should install the message callback"), CallbackResult, static_cast<int32>(asSUCCESS)))
		{
			return;
		}

		asIScriptModule* Module = NativeEngine->GetModule("ASHeaderShimRoundTrip", asGM_ALWAYS_CREATE);
		if (!TestRunner->TestNotNull(TEXT("HeaderShim native API test should create a native script module"), Module))
		{
			return;
		}

		const char* Source = "int Entry() { return 5; }";
		asIScriptFunction* Function = nullptr;
		const int32 CompileResult = Module->CompileFunction("ASHeaderShimRoundTrip", Source, 0, 0, &Function);
		if (!TestRunner->TestEqual(
				*FString::Printf(TEXT("HeaderShim native API test should compile the raw function successfully. Diagnostics: %s"), *MessageCollector.Format()),
				CompileResult,
				static_cast<int32>(asSUCCESS)))
		{
			return;
		}

		if (!TestRunner->TestNotNull(TEXT("HeaderShim native API test should receive a compiled function"), Function))
		{
			return;
		}

		TScopedAsRelease<asIScriptFunction> FunctionScope(Function);

		asIScriptContext* Context = NativeEngine->CreateContext();
		if (!TestRunner->TestNotNull(TEXT("HeaderShim native API test should create a native script context"), Context))
		{
			return;
		}

		TScopedAsRelease<asIScriptContext> ContextScope(Context);

		const int32 PrepareResult = Context->Prepare(Function);
		if (!TestRunner->TestEqual(TEXT("HeaderShim native API test should prepare the raw function successfully"), PrepareResult, static_cast<int32>(asSUCCESS)))
		{
			return;
		}

		const int32 ExecuteResult = Context->Execute();
		if (!TestRunner->TestEqual(TEXT("HeaderShim native API test should finish execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("HeaderShim native API test should return the compiled Entry() result"), static_cast<int32>(Context->GetReturnDWord()), 5);
	}
};

#endif
