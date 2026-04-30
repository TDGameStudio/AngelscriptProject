#include "Shared/AngelscriptTestMacros.h"
#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_builder.h"
#include "source/as_bytecode.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_AngelScriptSDK_AngelscriptBytecodeTests_Private
{
	asCModule* CreateBytecodeModule(asCScriptEngine* ScriptEngine, const char* ModuleName)
	{
		return static_cast<asCModule*>(ScriptEngine->GetModule(ModuleName, asGM_ALWAYS_CREATE));
	}
}

using namespace AngelscriptTest_AngelScriptSDK_AngelscriptBytecodeTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptBytecodeTests,
	"Angelscript.TestModule.AngelScriptSDK.Bytecode",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(InstructionSequence)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateBytecodeModule(BareEngine, "BytecodeInstructionSequence");
		if (!TestNotNull(TEXT("Bytecode instruction test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCByteCode ByteCode(&Builder);
		ByteCode.InstrDWORD(asBC_PshC4, 42);
		ByteCode.Instr(asBC_RET);

		TestTrue(TEXT("Bytecode should contain at least one dword after emitting instructions"), ByteCode.GetSize() > 0);
		TestNotNull(TEXT("Bytecode should expose the first instruction"), ByteCode.GetFirstInstr());
		TestEqual(TEXT("First emitted opcode should match asBC_PshC4"), static_cast<int32>(ByteCode.GetFirstInstr()->op), static_cast<int32>(asBC_PshC4));
		TestEqual(TEXT("Last emitted opcode should match asBC_RET"), ByteCode.GetLastInstr(), static_cast<int32>(asBC_RET));
		ASTEST_END_BARE
	}

	TEST_METHOD(Append)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateBytecodeModule(BareEngine, "BytecodeAppend");
		if (!TestNotNull(TEXT("Bytecode append test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCByteCode First(&Builder);
		asCByteCode Second(&Builder);
		First.InstrDWORD(asBC_PshC4, 10);
		Second.InstrDWORD(asBC_PshC4, 20);

		const int32 InitialSize = First.GetSize();
		First.AddCode(&Second);

		TestTrue(TEXT("AddCode should append the second sequence to the first one"), First.GetSize() > InitialSize);
		TestEqual(TEXT("The last dword payload should come from the appended sequence"), static_cast<int32>(First.GetLastInstrValueDW()), 20);
		ASTEST_END_BARE
	}

	TEST_METHOD(JumpResolution)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateBytecodeModule(BareEngine, "BytecodeJumpResolution");
		if (!TestNotNull(TEXT("Bytecode jump test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCByteCode ByteCode(&Builder);
		ByteCode.InstrDWORD(asBC_JMP, 1);
		ByteCode.Label(1);

		TestEqual(TEXT("ResolveJumpAddresses should resolve a forward label jump"), ByteCode.ResolveJumpAddresses(), 0);
		ASTEST_END_BARE
	}

	TEST_METHOD(Output)
	{
		asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
		ASTEST_BEGIN_BARE
		asCModule* Module = CreateBytecodeModule(BareEngine, "BytecodeOutput");
		if (!TestNotNull(TEXT("Bytecode output test should create a backing module"), Module))
		{
			return;
		}

		asCBuilder Builder(BareEngine, Module);
		asCByteCode ByteCode(&Builder);
		ByteCode.InstrDWORD(asBC_PshC4, 42);

		TArray<asDWORD> Buffer;
		Buffer.SetNumZeroed(ByteCode.GetSize());
		ByteCode.Output(Buffer.GetData());

		TestEqual(TEXT("Output should preserve the opcode in the first emitted dword"), static_cast<int32>(*reinterpret_cast<asBYTE*>(&Buffer[0])), static_cast<int32>(asBC_PshC4));
		TestEqual(TEXT("Output should preserve the dword payload for asBC_PshC4"), static_cast<int32>(Buffer[1]), 42);
		ASTEST_END_BARE
	}
};

#endif
