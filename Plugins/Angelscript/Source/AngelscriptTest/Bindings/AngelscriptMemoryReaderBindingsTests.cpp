#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/ScopeExit.h"
#include "Serialization/MemoryReader.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptMemoryReaderBindingsTests_Private
{
	static constexpr ANSICHAR MemoryReaderCompatModuleName[] = "ASMemoryReaderCompat";

	bool SetArgAddressChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Address,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind address argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgAddress(ArgumentIndex, Address),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		FString& OutExceptionString)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptMemoryReaderBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryReaderCompatBindingsTest,
	"Angelscript.TestModule.Bindings.MemoryReaderCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptMemoryReaderCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASMemoryReaderCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		MemoryReaderCompatModuleName,
		TEXT(R"(
int Entry()
{
	TArray<uint8> Data;
	Data.Add(0x41);
	Data.Add(0x42);
	Data.Add(0x10);
	Data.Add(0x00);
	Data.Add(0x78);
	Data.Add(0x56);
	Data.Add(0x34);
	Data.Add(0x12);
	Data.Add(0x43);
	Data.Add(0x44);
	Data.Add(0x45);
	Data.Add(0x46);

	FMemoryReader Reader(Data);
	if (Reader.TotalSize() != 12)
		return 10;
	if (Reader.Tell() != 0)
		return 20;
	if (Reader.ReadUInt8() != 0x41)
		return 30;
	if (Reader.Tell() != 1)
		return 40;
	if (Reader.ReadUInt16() != 0x1042)
		return 50;
	if (Reader.Tell() != 3)
		return 60;

	Reader.Seek(4);
	if (Reader.Tell() != 4)
		return 70;
	if (Reader.ReadInt32() != 0x12345678)
		return 80;
	if (Reader.Tell() != 8)
		return 90;

	Reader.Seek(8);
	TArray<uint8> TailBytes = Reader.ReadBytes(4);
	if (TailBytes.Num() != 4)
		return 100;
	if (TailBytes[0] != 0x43 || TailBytes[1] != 0x44 || TailBytes[2] != 0x45 || TailBytes[3] != 0x46)
		return 110;
	if (Reader.Tell() != 12)
		return 120;

	Reader.Seek(2);
	Reader.Skip(2);
	if (Reader.Tell() != 4)
		return 130;

	Reader.Seek(8);
	if (Reader.ReadAnsiString(4) != "CDEF")
		return 140;
	if (Reader.Tell() != 12)
		return 150;

	return 1;
}

void TriggerInvalidSkip(FMemoryReader& Reader)
{
	Reader.Skip(2);
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 ScriptResult = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, ScriptResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("FMemoryReader binding should preserve TotalSize, Tell, Seek, Skip, ReadBytes, ReadInt32, ReadUInt16, and ReadAnsiString semantics"),
		ScriptResult,
		1);

	AddExpectedError(TEXT("Skipping past array bounds"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASMemoryReaderCompat"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerInvalidSkip(FMemoryReader&)"), EAutomationExpectedErrorFlags::Contains, 1, false);

	TArray<uint8> NativeBytes;
	for (uint8 Value = 0; Value < 8; ++Value)
	{
		NativeBytes.Add(Value);
	}

	FMemoryReader NativeReader(NativeBytes);
	NativeReader.Seek(7);

	FString ExceptionString;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerInvalidSkip(FMemoryReader& Reader)"),
		[this, &NativeReader](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &NativeReader, TEXT("TriggerInvalidSkip"));
		},
		TEXT("TriggerInvalidSkip"),
		ExceptionString))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("FMemoryReader out-of-bounds skip should surface the expected runtime exception text"),
		ExceptionString,
		FString(TEXT("Skipping past array bounds")));
	bPassed &= TestEqual(
		TEXT("FMemoryReader out-of-bounds skip should leave the cursor at the pre-failure position"),
		static_cast<int32>(NativeReader.Tell()),
		7);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
